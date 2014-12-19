class Modul < ActiveRecord::Base
   has_many :lehrveranstaltungs

   enum studiengang: [:bachelor, :master]
   # pm = Pflichtmodul, km = Kernmodul, vm = Vertiefungsmodul, sm = Seminarmodul
   enum form: [:pm, :km, :vm, :sm]
   enum semesterturnus: [:ws, :ss]

   serialize :verwendbarkeit     
end
