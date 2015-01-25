class Lehrveranstaltung < ActiveRecord::Base
   belongs_to :modul

   # stored as arrays to support multiple days
   serialize :wochentag
   serialize :zeit_von
   serialize :zeit_bis
   serialize :raum
   serialize :dozent

   # list taken from http://pcai003.informatik.uni-leipzig.de:8892/sparql?default-graph-uri=&query=++SELECT+DISTINCT+%3Ftype%0D%0A++++WHERE%0D%0A++++%7B%0D%0A++++++%3Ftype+rdfs%3AsubClassOf+od%3ALV%0D%0A++++%7D&format=text%2Fhtml&timeout=0&debug=on
   enum form: [:Oberseminar, :Onlinekurs, :Praktikum, :Seminar, :Uebung, :Vorlesung, :VLUeb]
end
