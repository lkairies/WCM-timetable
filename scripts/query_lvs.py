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

def fake_modul_id(unit_uri):
  prefix_unit_as_modul = "UNIT-"
  return prefix_unit_as_modul + unit_uri.replace(PREFIX_ODS, "").replace(".", "-")

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

def get_unit_LVs():
  query = """
  SELECT DISTINCT ?titel ?lv_id ?form ?unit ?unit_name ?zeit_von ?zeit_bis ?raum ?dozent ?wochentag
    WHERE
    {
      ?lv_id rdf:type od:LV .
      ?lv_id rdf:type ?form .
      FILTER ( ?form != od:LV ) .
      ?kurs od:containsLV ?lv_id .
      ?unit od:containsKurs ?kurs .
      ?unit rdfs:label ?unit_name .
      FILTER NOT EXISTS { ?unit od:relatedModule ?modul } .
      ?lv_id rdfs:label ?titel .
      OPTIONAL {
        ?lv_id od:beginsAt ?zeit_von .
        ?lv_id od:endsAt ?zeit_bis
      } .
      OPTIONAL {
        ?lv_id od:locatedAt ?r .
        ?r rdfs:label ?raum
      } .
      ?lv_id od:servedBy ?person .
      ?person foaf:name ?dozent .
      ?lv_id od:dayOfWeek ?wochentag
    }
  """
  result = query_odfmi(query)

  # adds e1 and e2, stores result in e1
  def add_entries(e1, e2):
    if e2["dozent"][0] not in e1["dozent"]:
      e1["dozent"].append(e2["dozent"][0])

  #use a dictionary to find duplicate (lv, modul) entries
  #when we find duplicates, add them together.
  newlvs = dict()
  for entry in simplify_result(result):
    entry["dozent"] = [entry["dozent"]]
    entry["modul_id"] = fake_modul_id(entry["unit"])
    lv_id = entry["lv_id"].split("/")
    entry["semester"] = lv_id[-2]
    entry["lv_id"] = lv_id[-2] + "." + lv_id[-1]
    entry["form"] = entry["form"].replace(PREFIX_OD, "")
    if (entry["lv_id"],entry["unit"]) not in newlvs:
      newlvs[(entry["lv_id"],entry["unit"])] = entry
    else:
      add_entries(newlvs[(entry["lv_id"],entry["unit"])], entry)
  return list(newlvs.values())

#returns a list of dicts, each dict represents one lv.
# uniqueness is guaranteed for the pair (lv, modul)
def getLVs():
  #this is supposed to transform modul uri to modulnummer, but doesn't work with the virtuoso server
  # BIND ( ?modul_id AS replace(str(?modul), "^http://od.fmi.uni-leipzig.de/studium/", ""))
  query = """
  SELECT DISTINCT ?titel ?lv_id ?form ?modul_id ?unit ?unit_name ?zeit_von ?zeit_bis ?raum ?dozent ?wochentag
    WHERE
    {
      ?lv_id rdf:type od:LV .
      ?lv_id rdf:type ?form .
      FILTER ( ?form != od:LV ) .
      ?kurs od:containsLV ?lv_id .
      ?unit od:containsKurs ?kurs .
      ?unit rdfs:label ?unit_name .
      ?unit od:relatedModule ?modul_id .
      ?lv_id rdfs:label ?titel .
      OPTIONAL {
        ?lv_id od:beginsAt ?zeit_von .
        ?lv_id od:endsAt ?zeit_bis
      } .
      OPTIONAL {
        ?lv_id od:locatedAt ?r .
        ?r rdfs:label ?raum
      } .
      ?lv_id od:servedBy ?person .
      ?person foaf:name ?dozent .
      ?lv_id od:dayOfWeek ?wochentag
    }
  """
  result = query_odfmi(query)

  # adds e1 and e2, stores result in e1
  def add_entries(e1, e2):
    if e2["dozent"][0] not in e1["dozent"]:
      e1["dozent"].append(e2["dozent"][0])

  #use a dictionary to find duplicate (lv, modul) entries
  #when we find duplicates, add them together.
  newlvs = dict()
  for entry in simplify_result(result):
    entry["dozent"] = [entry["dozent"]]
    entry["modul_id"] = entry["modul_id"].replace(PREFIX_ODS, "")
    lv_id = entry["lv_id"].split("/")
    entry["semester"] = lv_id[-2]
    entry["lv_id"] = lv_id[-2] + "." + lv_id[-1]
    entry["form"] = entry["form"].replace(PREFIX_OD, "")
    if (entry["lv_id"],entry["unit"]) not in newlvs:
      newlvs[(entry["lv_id"],entry["unit"])] = entry
    else:
      add_entries(newlvs[(entry["lv_id"],entry["unit"])], entry)
  return get_unit_LVs() + list(newlvs.values())

def getUnitsAsModule():
  query="""
  SELECT DISTINCT ?modul_id ?titel
    WHERE
    {
      ?modul_id rdf:type od:Unit .
      FILTER NOT EXISTS { ?modul_id od:relatedModule ?modul .
        ?modul rdf:type od:Module } .
      OPTIONAL { ?modul_id od:hasUmfang ?sws }
      ?modul_id rdfs:label ?titel
    }
  """

  result = simplify_result(query_odfmi(query))
  for unit in result:
    unit["modul_id"] = fake_modul_id(unit["modul_id"])
  return result

def getModule():
  query="""
  SELECT DISTINCT ?modul_id ?sws ?titel
    WHERE
    {
      ?modul_id rdf:type od:Module .
      ?unit od:relatedModule ?modul_id .
      ?unit rdf:type od:Unit .
      OPTIONAL { ?unit od:hasUmfang ?sws } .
      ?modul_id rdfs:label ?titel
    }
"""

  # adds e1 and e2, stores result in e1
  def add_entries(e1, e2):
    if e1["sws"] != e2["sws"]:
      e1["sws"] = e1["sws"] + "\n" + e2["sws"]

  result = simplify_result(query_odfmi(query))

  newmoduls = dict()
  for sgmodul in result:
    modul_id = sgmodul["modul_id"].replace(PREFIX_ODS, "")
    sgmodul["modul_id"] = modul_id
    if modul_id not in newmoduls:
      newmoduls[modul_id] = sgmodul
    else:
      #print("adding:" + str(newmoduls[modul_id]) + "\n" + str(sgmodul), file=sys.stderr)
      add_entries(newmoduls[modul_id], sgmodul)
  return list(newmoduls.values()) + getUnitsAsModule()

if __name__ == "__main__":
  request = sys.argv[1]
  if request == "lehrveranstaltungen":
    result = getLVs()
  elif request == "module":
    result = getModule()
  else:
    print("ERROR: bad parameters", file=sys.stderr)
    quit(1)
  print(json.dumps(result))
