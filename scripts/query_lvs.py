#!/usr/bin/env python3
# requires python3-sparqlwrapper

import sys
import json

# suppress sparqlwrapper complaints
import warnings
warnings.simplefilter("ignore")

from SPARQLWrapper import SPARQLWrapper, JSON

PREFIX_HOST = "http://od.fmi.uni-leipzig.de/"
PREFIX_ODS = PREFIX_HOST+"studium/"
PREFIX_OD = PREFIX_HOST+"model/"
PREFIX_ROOMS = PREFIX_HOST+"rooms/"

def query_odfmi(query):
  sparql = SPARQLWrapper("http://pcai003.informatik.uni-leipzig.de:8892/sparql")
  sparql.setQuery(query)
  sparql.setReturnFormat(JSON)
  return sparql.query().convert()

def simplify_result(resultset):
  lvs = []
  for result in resultset["results"]["bindings"]:
    lv = dict()
    for key,field in result.items():
      lv[key] = field["value"]
    lvs.append(lv)
  return lvs

#returns a list of dicts, each dict represents one lv.
# uniqueness is guaranteed for the pair (lv, modul)
#parameter semester has the format
# (s|w)\d\d
#parameter studiengang is can be something like
# 'Inf.Bachelor', 'Inf.Bio', 'Inf.Master'
# use getStudiengaenge() for a complete list.
def getLVs(semester="w14", studiengang="Inf.Master"):
  #this is supposed to transform modul uri to modulnummer, but doesn't work with the virtuoso server
  # BIND ( ?modul_id AS replace(str(?modul), "^http://od.fmi.uni-leipzig.de/studium/", ""))
  query = """
  SELECT DISTINCT ?titel ?lv_id ?form ?modul_id ?zeit_von ?zeit_bis ?raum ?dozent ?wochentag
    WHERE
    {
      ?lv_id rdf:type od:LV .
  """
  query += 'FILTER regex(str(?lv_id), "' + PREFIX_HOST + semester + '/") .'
  query += """
      ?lv_id rdf:type ?form .
      FILTER ( ?form != od:LV ) .
      ?kurs od:containsLV ?lv_id .
      ?unit od:containsKurs ?kurs .
      ?unit od:relatedModule ?modul_id .
      ?unit od:recommendedFor ?sgsemester .
  """
  query += '?sgsemester od:toStudiengang <' + PREFIX_ODS + studiengang + '> .'
  query += """
      ?lv_id rdfs:label ?titel .
      ?lv_id od:beginsAt ?zeit_von .
      ?lv_id od:endsAt ?zeit_bis .
      ?lv_id od:locatedAt ?raum .
      ?lv_id od:servedBy ?person .
      ?person foaf:name ?dozent .
      ?lv_id od:dayOfWeek ?wochentag
    }
  """
  #~ query += " LIMIT 3"
  result = query_odfmi(query)

  # adds e1 and e2, stores result in e1
  def add_entries(e1, e2):
    if e1["dozent"] != e2["dozent"]:
      e1["dozent"] = e1["dozent"] + ";" + e2["dozent"]

  #use a dictionary to find duplicate (lv, modul) entries
  #when we find duplicates, add them together.
  newlvs = dict()
  for entry in simplify_result(result):
    entry["modul_id"] = entry["modul_id"].replace(PREFIX_ODS, "")
    entry["raum"] = entry["raum"].replace(PREFIX_ROOMS, "")
    entry["lv_id"] = entry["lv_id"].replace(PREFIX_HOST + semester +"/", "")
    entry["form"] = entry["form"].replace(PREFIX_OD, "").replace("Uebung", "Übung")
    if (entry["lv_id"],entry["modul_id"]) not in newlvs:
      newlvs[(entry["lv_id"],entry["modul_id"])] = entry
    else:
      add_entries(newlvs[(entry["lv_id"],entry["modul_id"])], entry)
  return list(newlvs.values())

def getStudienGaenge():
  query= """
  SELECT ?s
  WHERE
  {
    ?s rdf:type od:Studiengang
  }
  """
  result = simplify_result(query_odfmi(query))
  sgList = []
  for sg in result:
    sgList.append(sg["s"].replace(PREFIX_ODS, ""))
  return sgList

#~ print(getLVs("w14", "Inf.Master"))
#~ print(getStudienGaenge())
def main(semester, studiengang):
  print(json.dumps(getLVs(semester, studiengang)))


if __name__ == "__main__":
  if len(sys.argv) == 3:
    main(sys.argv[1], sys.argv[2])
  else:
    print("ERROR: invalid argument count")
