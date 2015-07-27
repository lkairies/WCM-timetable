# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'date'
require 'open-uri'
require 'nokogiri'
require 'sparql/client'

# TODO: move uris to config file
AKADEMISCHES_JAHR_URI = "https://www.zv.uni-leipzig.de/studium/studienorganisation/akademisches-jahr.html"
DATABASE_SPARQL_URI = "http://pcai003.informatik.uni-leipzig.de:8892/sparql"

PREFIX_HOST = "http://od.fmi.uni-leipzig.de/"
PREFIX_ODS = PREFIX_HOST+"studium/"
PREFIX_OD = PREFIX_HOST+"model/"
SPARQL_PREFIXES = "PREFIX od: <" + PREFIX_OD + ">\n" +
    "PREFIX ods: <" + PREFIX_ODS + ">\n"

# get semester information from the official webpage
# this includes:
#  > start and end date of the semester
#  > start and end date of lehrveranstaltungs in the semester
#  > list of days at which lehrveranstaltungs will actually happen (example: 0,1,2,3,4,5,7,8,9,10,12,14,...)
#    counting starts with the start date of lehrveranstaltungs in the semester
doc = Nokogiri::HTML(open(AKADEMISCHES_JAHR_URI))
doc.xpath('//*[@id="content-inner"]/div/table/tbody').each do |tbody_tag|
  semester = {}
  tbody_tag.children.each do |tr_tag|
    semester[tr_tag.children[0].content] = tr_tag.children[1].content
  end

  time = semester["Zeitraum"].split("bis")
  semester_begin = Date.parse(time[0])
  semester_end = Date.parse(time[1])

  # if the semester begins and ends in the same year, it's a sommersemester
  season = (semester_begin.year == semester_end.year) ? "s" : "w"
  # the id looks like this: "w14"
  semester_id = season + (semester_begin.year % 100).to_s

  db_semester = Semester.find_or_initialize_by( semester_id: semester_id )

  db_semester.begin = semester_begin
  db_semester.end = semester_end

  lvtime = semester["Lehrveranstaltungen"].split("bis")
  db_semester.lvbegin = Date.parse(lvtime[0])
  db_semester.lvend = Date.parse(lvtime[1])

  vorlesungstage = Array(0..(db_semester.lvend-db_semester.lvbegin))
  semester.each do |key, str|
    if str.include? "vorlesungsfrei"
      #logger.debug "break: #{str}"
      if str.include? " bis "
        dates = str.split(" bis ")
        break_begin = Date.parse(dates[0])
        break_end = Date.parse(dates[1])
        vorlesungstage -= Array((break_begin-db_semester.lvbegin).to_i..(break_end-db_semester.lvbegin).to_i)
      else
        break_date = Date.parse(str)
        #logger.debug "at: #{break_date}"
        vorlesungstage -= [(break_date-db_semester.lvbegin).to_i]
      end
    end
  end

  db_semester.vorlesungstage = vorlesungstage

  db_semester.save
end

def create_or_update_modul(modul)
  dbmodul = Modul.find_by( modul_id: modul["modul_id"] )
  if dbmodul
    dbmodul.update!(modul)
  else
    Modul.create!(modul)
  end
end

def query_odfmi(query)
  sparql = SPARQL::Client.new(DATABASE_SPARQL_URI)
  result = []
  sparql.query(query).each do |entry|
    hash = {}
    entry.bindings.each do |key,value|
      hash[key] = value.to_s
    end
    result.push(hash)
  end
  return result
end

def fake_modul_id(unit_uri)
  prefix_unit_as_modul = "UNIT-"
  return prefix_unit_as_modul + unit_uri.sub(PREFIX_ODS, "").gsub(".", "-")
end

def get_units_as_module()
  query="
  SELECT DISTINCT ?modul_id ?titel
    WHERE
    {
      ?modul_id rdf:type od:Unit .
      FILTER NOT EXISTS { ?modul_id od:relatedModule ?modul .
        ?modul rdf:type od:Module } .
      OPTIONAL { ?modul_id od:hasUmfang ?sws }
      ?modul_id rdfs:label ?titel
    }
  "

  result = query_odfmi(query)
  result.each do |unit|
    unit[:modul_id] = fake_modul_id(unit[:modul_id])
  end
  return result
end

def get_module()
  query="
  SELECT DISTINCT ?modul_id ?sws ?titel
    WHERE
    {
      ?modul_id rdf:type od:Module .
      ?unit od:relatedModule ?modul_id .
      ?unit rdf:type od:Unit .
      OPTIONAL { ?unit od:hasUmfang ?sws } .
      ?modul_id rdfs:label ?titel
    }
  "

  # adds e1 and e2, stores result in e1
  def add_entries(e1, e2)
    if e1[:sws] != e2[:sws]
      e1[:sws] = e1[:sws] + "\n" + e2[:sws]
    end
  end

  result = query_odfmi(query)

  newmoduls = {}
  result.each do |sgmodul|
    modul_id = sgmodul[:modul_id].sub(PREFIX_ODS, "")
    sgmodul[:modul_id] = modul_id
    if newmoduls.has_key?(modul_id)
      add_entries(newmoduls[modul_id], sgmodul)
    else
      newmoduls[modul_id] = sgmodul
    end
  end
  return newmoduls.values + get_units_as_module
end

# maybe the module table needs a reset before seeding values...?
get_module.each do |mod|
  create_or_update_modul(mod)
end

case Rails.env
when "production"
  jsonmaster = `scripts/parse_master.py http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ma-inf/ma-inf-module.html`
  jsonbachelor = `scripts/parse_bachelor.py http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ba-inf/ba-inf-module.html`
else
  tempdir = 'tmp'
  FileUtils.mkdir_p(tempdir) unless File.directory?(tempdir)
  ma_tmp_file = File.absolute_path(tempdir+'/ma-inf-module.pdf')
  unless File.exist?( ma_tmp_file )
    open(ma_tmp_file, 'wb') do |file|
      file << open('http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ma-inf/ma-inf-module.html').read
    end
  end
  jsonmaster = `scripts/parse_master.py file:#{ma_tmp_file}`
  ba_tmp_file = File.absolute_path(tempdir+'/ba-inf-module.pdf')
  unless File.exist?( ba_tmp_file )
    open(ba_tmp_file, 'wb') do |file|
      file << open('http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ba-inf/ba-inf-module.html').read
    end
  end
  jsonbachelor = `scripts/parse_bachelor.py file:#{ba_tmp_file}`
end

modules = JSON.parse(jsonmaster)
modules.each do |mod|
  create_or_update_modul(mod)
end

modules = JSON.parse(jsonbachelor)
modules.each do |mod|
  create_or_update_modul(mod)
end

query = SPARQL_PREFIXES + "
    SELECT DISTINCT ?studiengang ?modul_id
      WHERE
      {
        ?sg rdf:type od:Studiengang .
        ?sg rdfs:label ?studiengang .
        ?sgsem od:toStudiengang ?sg .
        ?modul_id od:toStudiengangSemester ?sgsem .
        ?modul_id rdf:type od:Module
      }"

result_modules = query_odfmi(query)
result_modules.each do |sgmodul|
  sgmodul[:modul_id] = sgmodul[:modul_id].sub(PREFIX_ODS, "")
end

query = SPARQL_PREFIXES + "
  SELECT DISTINCT ?studiengang ?modul_id
    WHERE
    {
      ?sg rdf:type od:Studiengang .
      ?sg rdfs:label ?studiengang .
      ?sgsem od:toStudiengang ?sg .
      ?modul_id od:recommendedFor ?sgsem .
      ?modul_id rdf:type od:Unit .
      FILTER NOT EXISTS { ?modul_id od:relatedModule ?mod }
    }"

result_units = query_odfmi(query)
result_units.each do |sgmodul|
  sgmodul[:modul_id] = fake_modul_id(sgmodul[:modul_id])
end

sgmodule = result_modules + result_units

StudiengangModul.transaction do
  StudiengangModul.destroy_all
  sgmodule.each do |sm|
    StudiengangModul.create!(sm)
  end
end

json_lehrveranstaltungen = `scripts/query_lvs.py lehrveranstaltungen`
lvs = JSON.parse(json_lehrveranstaltungen)
lvs.each do |lv|
  Lehrveranstaltung.create!(lv)
end
