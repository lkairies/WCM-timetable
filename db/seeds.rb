# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

jsonmaster = `scripts/parse_master.py`
modules = JSON.parse(jsonmaster)
modules.each do |mod|
  Modul.create!(mod)
end

jsonbachelor = `scripts/parse_bachelor.py`
modules = JSON.parse(jsonbachelor)
modules.each do |mod|
  Modul.create!(mod)
end

jsonSM = `scripts/query_lvs.py studiengangmodule`
sgmodule = JSON.parse(jsonSM)
sgmodule.each do |sm|
  StudiengangModul.create!(sm)
end

#todo: autodetect semester based on current date
semester = "w14"
jsonLV = `scripts/query_lvs.py lehrveranstaltungen #{semester}`
lvs = JSON.parse(jsonLV)
lvs.each do |lv|
  Lehrveranstaltung.create!(lv)
end
