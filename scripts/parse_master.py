#!/usr/bin/env python3
#################################
# vorraussetzungen: pdftotext version 0.18.4
# python3, python3-urllib3
#
import sys
import io
import json
import re
from parser_helpers import *
MODULE_DELIMITER_pdftotext = "Master of Science Informatik\nAkademischer Grad\n\nModulnummer\n\nModulform\n\nMaster of Science\n\n"

#Es gibt immer zwei Titel für ein Modul (deutsch, englisch).
#Bei manchen Modulen ist direkt nach dem Titel eine Angabe zur Modulart (Kern- / Vertiefungsmodul.
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
        title = lines[0]
        art = lines[1]
    elif len(lines) == 3:
        title = lines[0] + " " + lines[1]
        art = lines[2]
    else:
        title = ""
        art = ""
    return title, art

def parse_module(module_string):
    #dictionary keys must match database schema
    modul = dict()
    modul['studiengang'] = 'master'
    stream = io.StringIO(module_string)
    modul['modul_id'] = stream.readline().strip()
    stream.readline()
    modul['form'] = stream.readline().strip()
    seek_to_value_for_key(stream, 'Modultitel')
    modul['titel'], modul['art'] = get_title(stream)
    seek_to_value_for_key(stream, 'Modultitel (englisch)')
    modul['titel_englisch'], modul['art_englisch'] = get_title(stream)
    seek_to_value_for_key(stream, 'Empfohlen für:')
    modul['empfohlen_fuer'] = get_single_line_value(stream)
    seek_to_value_for_key(stream, 'Verantwortlich')
    modul['verantwortlich'] = get_single_line_value(stream)
    seek_to_value_for_key(stream, 'Dauer')
    modul['dauer'] = get_single_line_value(stream)
    seek_to_value_for_key(stream, 'Modulturnus')
    modul['semesterturnus'] = get_semesterturnus(stream)
    #TODO: Lehrformen
    seek_to_value_for_key(stream, 'Lehrformen')
    modul['lehrformen'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Arbeitsaufwand')
    modul['credits'] = get_single_line_value(stream).split()[0]
    seek_to_value_for_key(stream, 'Verwendbarkeit')
    modul['verwendbarkeit'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Ziele')
    #TODO: Verwendbarkeit
    #Anmerkung: mehrere Zeilen möglich, unterschiedliche arten von zeilen (•, -, )
    modul['ziele'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Inhalt')
    modul['beschreibung'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Teilnahmevoraussetzungen')
    modul['teilnahmevorraussetzungen'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Literaturangabe')
    modul['literaturangabe'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Vergabe von Leistungspunkten')
    modul['vergabe_von_lp'] = get_multiline_value_until_key_and_seek_to_its_value(stream, 'Prüfungsleistungen und -vorleistungen')
    modul['pruefungsleistungen'] = get_multiline_value_until_eof(stream)

    return modul

def parse(pdftotext_string):
    txtmodules = re.sub(PAGE_BREAK_REGEX, "\n\n", pdftotext_string).split(MODULE_DELIMITER_pdftotext)
    #ignore first page, because its empty
    itermodules = iter(txtmodules)
    next(itermodules)
    modules = []
    for txtmodule in itermodules:
        modules.append(parse_module(txtmodule))
    return modules

def main(url):
    module = parse(pdf_url_to_text_string(url))
    return module

if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(json.dumps(main(sys.argv[1])))
    else:
        print('missing argument', file=sys.stderr)
