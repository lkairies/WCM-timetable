#!/usr/bin/env python3

import os

from subprocess import call

from match_lv import *

scriptdir = os.path.dirname(os.path.realpath(__file__))

test_directory = os.path.dirname(os.path.realpath(__file__))+"/test"

crawled_filename = test_directory + "/crawled.json"

def test_precondition_testCrawler():
  if not os.path.isfile(crawled_filename):
    #replace this with a call to the crawler tests.
    print("INFO: crawled LVs not present. starting crawler...")
    call(["scrapy", "runspider", scriptdir+"/lv_spider.py", "-o", crawled_filename])
    print("INFO: crawler has finished.")
  if not os.path.isfile(crawled_filename):
    print("ERROR: Could not crawl LVs.")
    return False
  else:
    return True

def test_lv(title, modulnummer, assert_url, corpus):
  url = find_best_match(title, modulnummer, corpus)
  if url == assert_url:
    print("SUCCESS!")
  else:
    print("FAIL!")
    print(url)

def test():
  test_normalize()

  corpus = json.load(open(crawled_filename))

  #!!!!!! WARNING: some of these test cases WILL FAIL after 2015-03-31 !!!!!!
  #Wintersemester 2014 (yes, the dh link is correct)
  test_lv("Algorithmen und Datenstrukturen 1 Vorlesung", "10-201-2001-1", "http://asv.informatik.uni-leipzig.de/courses/162", corpus)
  test_lv("Vorlesung Eingebettete Systeme", "10-202-2126", "http://www.informatik.uni-leipzig.de/ti/lehre/aktuellessemester/vorlesung-es.html", corpus)
  test_lv("Seminar Introduction to Humanities Programming with Python", "10-202-2335", "http://www.dh.uni-leipzig.de/wo/courses/digital-philology-at-the-university-of-leipzig-sommersemester-20132014/", corpus)
  test_lv("Seminar Methoden der digitalen Textkritik und kollaboratives Editieren", "10-202-2012", "http://www.dh.uni-leipzig.de/wo/courses/overview-of-digital-philology-wintersemester-20132014/", corpus)
  test_lv("Seminar Mobile Peer-to-Peer-Systeme", "10-202-2124", "http://rvs.informatik.uni-leipzig.de/de/lehre/WS1415/seminare/mp2ps/", corpus)
  # hard to find, because of generic lv name and modulnummer
  test_lv("Bachelor- und Masterseminar ASV", "10-202-2011", "http://asv.informatik.uni-leipzig.de/courses/159", corpus)
  # hard to find, because the olat page does not contain the lv title (and we don't crawl the OLAT)
  # there are some more pages for this lv:
  # http://www.imn.htwk-leipzig.de/~waldmann/lehre.html
  # http://bis.informatik.uni-leipzig.de/HansGertGraebe
  test_lv("Symbolisches Rechnen - Vorlesung", "10-202-2012", "https://olat.informatik.uni-leipzig.de/url/RepositoryEntry/55443457", corpus)
  test_lv("Problemseminar: Graph Data Management", "10-202-2011", "http://dbs.uni-leipzig.de/study/ws_2014_15/seminar", corpus)
  test_lv("Bio Data Management", "10-202-2216", "http://dbs.uni-leipzig.de/stud/2014ws/biodm", corpus)
  test_lv("Vorlesung Sequenzanalyse und Genomik", "10-202-2207", "http://www.bioinf.uni-leipzig.de/teaching/currentClasses/class188.html", corpus)
  test_lv("Modellierung biologischer und molekularer Systeme - Vorlesung", "10-202-2410", "http://www.imise.uni-leipzig.de/Lehre/Semester/2014-15/MbumS/index.jsp", corpus)
  test_lv("Spezialvorlesung Graphen und Netzwerke in der Biologie", "10-202-2205", "http://www.imise.uni-leipzig.de/Lehre/Semester/2014-15/MbumS/index.jsp", corpus)

def test_normalize():
  print("testing title normalize...")
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

if not test_precondition_testCrawler():
  quit()
test()
