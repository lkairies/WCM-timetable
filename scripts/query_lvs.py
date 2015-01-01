#!/usr/bin/env python3
# requires python3-sparqlwrapper

from SPARQLWrapper import SPARQLWrapper, JSON

sparql = SPARQLWrapper("http://pcai003.informatik.uni-leipzig.de:8892/sparql")
sparql.setQuery("""
  SELECT DISTINCT ?title ?lv ?modul ?start ?end ?location
  WHERE
  {
    ?lv rdf:type od:LV .
    ?kurs od:containsLV ?lv .
    ?unit od:containsKurs ?kurs .
    ?unit od:relatedModule ?modul .
    ?unit od:recommendedFor ?sgsemester .
    ?sgsemester od:toStudiengang <http://od.fmi.uni-leipzig.de/studium/Inf.Master> .
    ?lv rdfs:label ?title .
    ?lv od:beginsAt ?start .
    ?lv od:endsAt ?end .
    ?lv od:locatedAt ?location .
    FILTER regex(str(?lv), "http://od.fmi.uni-leipzig.de/w14/")
  } LIMIT 3
""")
sparql.setReturnFormat(JSON)
results = sparql.query().convert()

def simplify_result(resultset):
  lvs = []
  for result in resultset["results"]["bindings"]:
    lv = dict()
    for key,field in result.items():
      lv[key] = field["value"]
    lvs.append(lv)
  return lvs
print(simplify_result(results))
