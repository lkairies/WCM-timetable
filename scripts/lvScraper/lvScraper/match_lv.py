#!/usr/bin/env python3

import lxml.html
import re
#~ from string import punctuation

import json
import sys

from difflib import SequenceMatcher

lv_forms = frozenset([u'Übung', 'Vorlesung', 'Praktikum', 'Seminar'])

def normalize_title_and_get_lv_form( string ):
    #~ node = lxml.html.fromstring(string)
    #~ text = lxml.html.tostring(node, method="text", encoding='unicode')
    # this is supposed to match any whitespace and punctuation characters
    # need UNICODE flag for special whitespaces
    #~ r = re.compile(r'[\s{}]+'.format(re.escape(punctuation)), flags=re.UNICODE)
    r = re.compile(r'\W+', flags=re.UNICODE)

    form = ''
    title_tokens = []
    for t in r.split(string):
        # test for empty string. this should not happen! check splitting regex!!!! (python bug?)
        if t == '':
            #~ print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! empty string after split")
            #~ print(text)
            #~ print(title_tokens)
            pass
        elif t in lv_forms:
            if form == '':
                form = t
        else:
            title_tokens.append(t)
    if form == '':
        form = 'unknown'
    return ({"title": " ".join(title_tokens), "lv_form": form})

# returns float between 0 and 1
def compare_title(title_candidate, title):
  result = 0

  #get title similarity without form
  result = 0.7 * SequenceMatcher(None, title["title"], title_candidate["title"]).ratio()

  #weight form match a little less than title match
  if title["lv_form"] == title_candidate["lv_form"]:
    result = 0.3 + result

  return result

def compare_webpage_to_title_and_modul(webpage, title, modulnummer):
  score = 0.0

  #evaluate title similarity
  title = normalize_title_and_get_lv_form(title)
  #this list can be extended by xpaths that contain lv titles in webpages
  title_xpaths = ["//h1", "//h2", "//h3", "//h4"]
  title_candidates = []
  title_candidates.append(webpage['html_title_text'])
  root = lxml.html.fromstring(webpage['html_body'])
  for path in title_xpaths:
    nodes = root.xpath(path)
    for node in nodes:
      text = lxml.html.tostring(node, method="text", encoding='unicode')
      title_candidates.append(text)
  scores = []
  for title_candidate in title_candidates:
    title_candidate = normalize_title_and_get_lv_form(title_candidate)
    scores.append(compare_title(title_candidate, title))
    #~ print(scores[-1], title_candidate)
  score = score + (0.5 * max(scores))

  #increase score if we find the modulnummer in the page
  page_body_text = lxml.html.tostring(root, method="text", encoding='unicode')
  if modulnummer in page_body_text:
    score += 0.5
  return score



def find_best_match(title_string, modulnummer, corpus):

  print("finding webpage for:", title_string)
  #store pairs of (score, url)
  urls_score = []
  for webpage in corpus:
    urls_score.append( ( compare_webpage_to_title_and_modul(webpage, title_string, modulnummer), webpage['url'] ) )
    #~ print("score:",urls_score[-1][0], "\tpage:",urls_score[-1][1])
  return max(urls_score)[1]

def main():
  title_string = sys.argv[1]
  modulnummer = sys.argv[2]
  json_database_file = sys.argv[3]
  print(find_best_match(title_string, modulnummer, json_load(open(json_database_file))))

def test_lv(title, modulnummer, assert_url, corpus):
  url = find_best_match(title, modulnummer, corpus)
  if url == assert_url:
    print("SUCCESS!")
  else:
    print("FAIL!")
    print(url)

def test():
  #~ corpus = json.loads(json_test)
  corpus = json.load(open("test_data.json"))

  #Wintersemester 2014 (yes, the dh link is correct)
  test_lv("Algorithmen und Datenstrukturen 1 Vorlesung", "10-201-2001-1", "http://asv.informatik.uni-leipzig.de/courses/162", corpus)
  test_lv("Vorlesung Eingebettete Systeme", "10-202-2126", "http://www.informatik.uni-leipzig.de/ti/lehre/aktuellessemester/vorlesung-es.html", corpus)
  test_lv("Seminar Introduction to Humanities Programming with Python", "10-202-2335", "http://www.dh.uni-leipzig.de/wo/courses/digital-philology-at-the-university-of-leipzig-sommersemester-20132014/", corpus)
  test_lv("Seminar Mobile Peer-to-Peer-Systeme", "10-202-2124", "http://rvs.informatik.uni-leipzig.de/de/lehre/WS1415/seminare/mp2ps/", corpus)
  test_lv("Bachelor- und Masterseminar ASV", "10-202-2011", "http://asv.informatik.uni-leipzig.de/courses/159", corpus)

  test_normalize()

def test_normalize():
    title = normalize_title_and_get_lv_form("Algorithmen und Datenstrukturen 1  -\xdcbung Vorlesung")
    if title["title"] != "Algorithmen und Datenstrukturen 1" or title["lv_form"] != u'Übung':
        print("FAIL!")
    else:
        print("SUCCESS!")
    title = normalize_title_and_get_lv_form(u"Algorithmen und Datenstrukturen 1  - Übung Vorlesung")
    if title["title"] != "Algorithmen und Datenstrukturen 1" or title["lv_form"] != u'Übung':
        print("FAIL!")
    else:
        print("SUCCESS!")
#~ test()
