class Lehrveranstaltung < ActiveRecord::Base
   belongs_to :modul

   # stored as arrays to support multiple days
   serialize :wochentag
   serialize :zeit_von
   serialize :zeit_bis
   serialize :raum

end
