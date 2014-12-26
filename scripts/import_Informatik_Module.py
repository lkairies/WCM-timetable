#!/usr/bin/env python3
#################################
# vorraussetzungen: python3, python3-urllib3
#
import parse_bachelor, parse_master
import urllib.request
import subprocess
import os
import json

current_modules_bachelor = \
'http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ba-inf/ba-inf-module.html'
current_modules_master = \
'http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ma-inf/ma-inf-module.html'

testurl_bachelor = 'file:///home/joki/Studium/Master/WCM/WCM-timetable/scripts/test/ba-inf-module.pdf'
testurl_master = 'file:///home/joki/Studium/Master/WCM/WCM-timetable/scripts/test/ma-inf-module.pdf'

def pdf_url_to_text_string(url):
    pdf_stream = urllib.request.urlopen(url)
    pdftotext = subprocess.Popen(["pdftotext", "-", "-"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    return pdftotext.communicate(pdf_stream.read())[0].decode()

bachelor_module = parse_bachelor.parse(pdf_url_to_text_string(testurl_bachelor))
master_module = parse_master.parse(pdf_url_to_text_string(testurl_master))

print(json.dumps(bachelor_module))
print(json.dumps(master_module))
