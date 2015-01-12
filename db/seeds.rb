# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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

#todo: autodetect semester based on current date
jsonLV = `scripts/query_lvs.py lehrveranstaltungen`
lvs = JSON.parse(jsonLV)
lvs.each do |lv|
  Lehrveranstaltung.create!(lv)
end
