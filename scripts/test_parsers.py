#!/usr/bin/env python3
import os
import urllib

import parse_master

test_directory = os.path.dirname(os.path.realpath(__file__))+"/test"

pdfurl = "http://db.uni-leipzig.de/bekanntmachung/dokudownload.php?dok_id=694"
pdf_filename = test_directory + "/ma-inf-module.pdf"

def test_precondition_getpdf():
  if not os.path.isfile(pdf_filename):
    print("INFO: pdf file not present. downloading...")
    urllib.urlretrieve(pdfurl, pdf_filename)
    print("INFO: download complete")
  if not (os.path.isfile(pdf_filename) and os.path.getsize(pdf_filename) == 691440):
    print("ERROR: Could not get required pdf file:", pdf_filename)
    return False
  else:
    return True

def test_forms():
  module = parse_master.main('file://'+pdf_filename)
  forms = ['Wahlpflicht', 'Wahlpflicht', 'Wahl', 'Wahl', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahl', 'Wahlpflicht', 'Wahl', 'Wahl', 'Wahl', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahl', 'Wahl', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahl', 'Wahlpflicht', 'Wahlpflicht', 'Wahl', 'Wahl', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Wahlpflicht', 'Pflicht', 'Wahlpflicht']
  for i, modul in enumerate(module):
    if forms[i] != modul['form']:
      #~ print("ERROR: wrong form")
      return False
  return True

if not test_precondition_getpdf():
  quit()
print("testing forms... ")
if test_forms():
  print("SUCCESS!")
else:
  print("FAIL!")
