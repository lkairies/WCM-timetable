#!/usr/bin/env python3
import urllib.request
import subprocess

PAGE_BREAK_REGEX = r"\n\d\d?\. \w+ \d\d\d\d\n\n\f" # example: "26. September 2013"

def pdf_url_to_text_string(url):
    pdf_stream = urllib.request.urlopen(url)
    pdftotext = subprocess.Popen(["pdftotext", "-", "-"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    return pdftotext.communicate(pdf_stream.read())[0].decode()

#Annahme: Es gibt immer eine leere Zeile nach einem key.
def seek_to_value_for_key(module, key):
    line = ''
    while line.strip() != key:
        line = module.readline()
    module.readline()

def get_single_line_value(module):
    return module.readline().strip()

def get_bullet_values(module):
    #TODO: implement for 'Lehrformen'
    return

def skip_next_line_if_empty(stream):
    offset = stream.tell()
    if stream.readline().strip() != "":
        stream.seek(offset)

#this function has many if-statements, because we can't be sure if there are empty lines or not.
def get_multiline_value_until_key_and_seek_to_its_value(stream, until_key):
    lines = []
    while True:
        line = stream.readline().strip()
        if line == until_key:
            skip_next_line_if_empty(stream)
            break
        elif line == '':
            nextline = stream.readline().strip()
            if nextline == until_key:
                skip_next_line_if_empty(stream)
                break
            else:
                lines.append(line)
                lines.append(nextline)
        else:
            lines.append(line)
    while len(lines) > 0 and lines[-1] == "":
        lines.pop()
    return "\n".join(lines)

def get_multiline_value_until_eof(stream):
    lines = []
    while True:
        line = stream.readline()
        if not line:
            break
        lines.append(line.strip())
    while len(lines) > 0 and lines[-1] == "":
        lines.pop()
    return "\n".join(lines)
