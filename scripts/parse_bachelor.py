#!/usr/bin/env python3
#################################
# vorraussetzungen: pdftotext version 0.18.4
# python3, python3-urllib3
#
import os
import sys
import io
import json
from parser_helpers import *
DATE_OF_PDF = "22. Juli 2010"
MODULE_DELIMITER_pdftotext = "Bachelor of Science Informatik\nAkademischer Grad\n\nModulnummer\n\nModulform\n\nBachelor of Science\n\n"
PAGE_BREAK_STRING_pdftotext = "\n\n"+DATE_OF_PDF+"\n\n\f"

current_modules = \
'http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ba-inf/ba-inf-module.html'

testurl = 'file://'+os.path.dirname(os.path.realpath(__file__))+'/test/ba-inf-module.pdf'

#Unterschiedliche Struktur zum Master-PDF
#Die Angabe zur Modulart steht VOR dem Modulnamen
#Bei manchen Modulen erstreckt sich der Titel über zwei Zeilen.
#Annahme: Es gibt kein Modul, welches keine Modulart hat und dessen Titel mehr als eine Zeile belegt.
def get_title(module):
    lines = []
    while True:
        line = module.readline().strip()
        if line == '':
            break
        lines.append(line)
    if len(lines) == 1:
        title = lines[0]
        art = ""
    elif len(lines) == 2:
        title = lines[1]
        art = lines[0]
    elif len(lines) == 3:
        title = lines[1] + " " + lines[2]
        art = lines[0]
    else:
        title = ""
        art = ""
    return title, art

def parse_module(module_string):
    modul = dict()
    stream = io.StringIO(module_string)
    modul['Modulnummer'] = stream.readline().strip()
    stream.readline()
    modul['Modulform'] = stream.readline().strip()
    seek_to_value_for_key(stream, 'Modultitel')
    modul['Modultitel'], modul['Modulart'] = get_title(stream)
    seek_to_value_for_key(stream, 'Empfohlen für:')
    modul['Empfohlen für'] = get_single_line_value(stream)
    seek_to_value_for_key(stream, 'Verantwortlich')
    modul['Verantwortlich'] = get_single_line_value(stream)
    seek_to_value_for_key(stream, 'Dauer')
    modul['Dauer'] = get_single_line_value(stream)
    seek_to_value_for_key(stream, 'Modulturnus')
    modul['Modulturnus'] = get_single_line_value(stream)
    #TODO: Lehrformen
    seek_to_value_for_key(stream, 'Lehrformen')
    modul['Lehrformen'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Arbeitsaufwand')
    modul['Arbeitsaufwand'] = get_single_line_value(stream)
    seek_to_value_for_key(stream, 'Verwendbarkeit')
    modul['Verwendbarkeit'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Ziele')
    #TODO: Verwendbarkeit
    #Anmerkung: unterschiedliche arten von zeilen (•, -, )
    modul['Ziele'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Inhalt')
    modul['Inhalt'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Teilnahmevoraussetzungen')
    modul['Teilnahmevorraussetzungen'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Literaturangabe')
    modul['Literaturangabe'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Vergabe von Leistungspunkten')
    modul['Vergabe von Leistungspunkten'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Prüfungsformen und -leistungen')
    modul['Prüfungsformen und -leistungen'] = get_multiline_value_until_eof(stream)

    return modul

def parse(pdftotext_string):
    txtmodules = pdftotext_string.replace(PAGE_BREAK_STRING_pdftotext, "\n\n").split(MODULE_DELIMITER_pdftotext)
    #ignore first page, because its empty
    itermodules = iter(txtmodules)
    next(itermodules)
    modules = []
    for txtmodule in itermodules:
        modules.append(parse_module(txtmodule))
    return modules

def main(url):
    module = parse(pdf_url_to_text_string(url))
    print(json.dumps(module))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "current":
            main(current_modules)
        else:
            main(sys.argv[1])
    else:
        main(testurl)
