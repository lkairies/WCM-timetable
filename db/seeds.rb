# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'date'

json_semester_info = `scripts/get_semester_info.py`
semesters = JSON.parse(json_semester_info)
semesters.each do |semester|
  db_semester = Semester.new

  time = semester["Zeitraum"].split("bis")
  db_semester.begin = Date.parse(time[0])
  db_semester.end = Date.parse(time[1])

  semester_year = db_semester.begin.year-2000
  # if begin and end are in the same year, it's a sommersemester
  if db_semester.begin.year == db_semester.end.year
    semester_id = "s" + semester_year.to_s
  else
    semester_id = "w" + semester_year.to_s
  end
  db_semester.semester_id = semester_id

  lvtime = semester["Lehrveranstaltungen"].split("bis")
  db_semester.lvbegin = Date.parse(lvtime[0])
  db_semester.lvend = Date.parse(lvtime[1])

  vorlesungstage = Array(0..(1+(db_semester.end-db_semester.begin)))
  semester.each do |key, str|
    if str.include? "vorlesungsfrei"
      #logger.debug "break: #{str}"
      if str.include? " bis "
        dates = str.split(" bis ")
        break_begin = Date.parse(dates[0])
        break_end = Date.parse(dates[1])+1 # add one because the end of break date is included in the break
        vorlesungstage -= Array((break_begin-db_semester.begin).to_i..(break_end-db_semester.begin).to_i)
      else
        break_date = Date.parse(str)
        #logger.debug "at: #{break_date}"
        vorlesungstage -= [(break_date-db_semester.begin).to_i]
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

jsonMods = `scripts/query_lvs.py module`
modules = JSON.parse(jsonMods)
modules.each do |mod|
  create_or_update_modul(mod)
end

jsonmaster = `scripts/parse_master.py`
modules = JSON.parse(jsonmaster)
modules.each do |mod|
  create_or_update_modul(mod)
end

jsonbachelor = `scripts/parse_bachelor.py`
modules = JSON.parse(jsonbachelor)
modules.each do |mod|
  create_or_update_modul(mod)
end

jsonSM = `scripts/query_lvs.py studiengangmodule`
sgmodule = JSON.parse(jsonSM)
sgmodule.each do |sm|
  StudiengangModul.create!(sm)
end

jsonLV = `scripts/query_lvs.py lehrveranstaltungen`
lvs = JSON.parse(jsonLV)
lvs.each do |lv|
  Lehrveranstaltung.create!(lv)
end
