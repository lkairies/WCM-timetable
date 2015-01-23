#!/usr/bin/env python3
########################
# converts semesterinfo tables into a list of dictionaries
import urllib.request
import lxml.html
import json

uri = "https://www.zv.uni-leipzig.de/studium/studienorganisation/akademisches-jahr.html"
tree = lxml.html.parse(urllib.request.urlopen(uri))
root = tree.getroot()

tables = root.xpath('//*[@id="content-inner"]/div/table')

parsed_tables = []
for table in tables:
    table_contents = dict()
    tbody = table.xpath('tbody')[0]
    for tr in tbody.iterchildren():
        table_contents[tr.getchildren()[0].text_content()] = tr.getchildren()[1].text_content()
    parsed_tables.append(table_contents)
print(json.dumps(parsed_tables))
