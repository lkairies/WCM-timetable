#!/usr/bin/env python3

import lxml.html
import re
#~ from string import punctuation

import json
import sys

from difflib import SequenceMatcher

lv_forms = frozenset([u'Übung', 'Vorlesung', 'Praktikum', 'Seminar'])

def normalize_title_and_get_lv_form( string ):
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

  #weight form match a little less than title similarity
  if title["lv_form"] == title_candidate["lv_form"]:
    result = 0.3 + result
  #~ print(result, title_candidate)
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
  nodes = []
  for link in webpage["links"]:
    nodes.append(lxml.html.fromstring(link))
  for path in title_xpaths:
    nodes += root.xpath(path)
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

def split_corpus_to_pages_and_links(corpus):
  pages = []
  links = []
  for item in corpus:
    if "url" in item:
      pages.append(item)
    else:
      links.append(item)
  return pages, links

def find_best_match(title_string, modulnummer, corpus):
  print("finding webpage for:", title_string)
  pages, links = split_corpus_to_pages_and_links(corpus)
  #store pairs of (score, url)
  urls_score = []
  for webpage in pages:
    links_to_page = []
    for link in links:
      if link["linkurl"] == webpage["url"]:
        links_to_page.append(link["html_a"])
    webpage["links"] = links_to_page
    urls_score.append( ( compare_webpage_to_title_and_modul(webpage, title_string, modulnummer), webpage['url'] ) )

    #~ print("score:",urls_score[-1][0], "\tpage:",urls_score[-1][1])
  return max(urls_score)[1]

def main():
  title_string = sys.argv[1]
  modulnummer = sys.argv[2]
  json_database_file = sys.argv[3]
  print(find_best_match(title_string, modulnummer, json_load(open(json_database_file))))
