class Modul < ActiveRecord::Base
   has_many :lehrveranstaltungs

   enum studiengang: [:bachelor, :master]
   # pm = Pflichtmodul, km = Kernmodul, vm = Vertiefungsmodul, sm = Seminarmodul
   enum form: [:Wahl, :Wahlpflicht, :Pflicht]
   enum semesterturnus: ["jedes Wintersemester", "jedes Sommersemester", "jedes Semester"]

   serialize :verwendbarkeit     
end
