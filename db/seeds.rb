# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
lvs1 = Lehrveranstaltung.create([{ titel: "Datenbanken 1", modul_id: "000-111-222", dozent: "Rahm", form: :vorlesung, wochentag: :mo, zeit_von: "11:15", zeit_bis: "12:45", raum: "S3-14", weblink: "foo.org/db1"}, { titel: "Datenbanken2", dozent: "Rahm", form: :vorlesung, wochentag: :di, zeit_von: "11:15", zeit_bis: "12:45", raum: "S3-12", weblink: "foo.org/db2"}])

lvs2 = Lehrveranstaltung.create([{ titel: "Grundlagen theoretische Informatik", modul_id: "000-111-222", dozent: "Bogdan", form: :vorlesung, wochentag: [:mi, :fr], zeit_von: ["11:15", "11:15"], zeit_bis: ["12:45", "12:45"], raum: ["S3-14", "S3-12"], weblink: "foo.org/ti"}])

Modul.create([{ titel: "Grundlagen Datenbanken", nummer: "000-111-222", studiengang: :bachelor, beschreibung: "FOO FOO FOO \n FOO FOO", credits: 5, semesterturnus: "jedes Wintersemester", verantwortlich: "AG Datenbanken", verwendbarkeit: [:ai, :pi]}])

Modul.create([{ titel: "Technische Informatik", nummer: "111-222-222", studiengang: :bachelor, beschreibung: "FOO FOO FOO \n FOO FOO", credits: 5, semesterturnus: "jedes Sommersemester", verantwortlich: "AG Technische Informatik", verwendbarkeit: [:tei]}])

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

jsonLV = `scripts/query_lvs.py w14 Inf.Master`
lvs = JSON.parse(jsonLV)
lvs.each do |lv|
  Lehrveranstaltung.create!(lv)
end
