import scrapy

#from scrapy import Spider, Item, Field
from scrapy.contrib.spiders import CrawlSpider, Rule
from scrapy.contrib.linkextractors import LinkExtractor
from scrapy.utils.response import get_base_url
from urlparse import urljoin

from items import CourseItem, LinkingElement

class ASVSpider(CrawlSpider):
  name = 'lv'
  allowed_domains = ['www.informatik.uni-leipzig.de',
                     'dbs.uni-leipzig.de',
                     'asv.informatik.uni-leipzig.de',
                     'rvs.informatik.uni-leipzig.de',
                     'www.dh.uni-leipzig.de',
                     'www.bioinf.uni-leipzig.de',
                     'www.imise.uni-leipzig.de'
                    ]

  start_urls = [
     'http://asv.informatik.uni-leipzig.de/courses/'
    ,'http://www.informatik.uni-leipzig.de/ti/lehre/aktuellessemester.html'
    ,'http://rvs.informatik.uni-leipzig.de/de/lehre/'
    ,'http://www.dh.uni-leipzig.de/wo/courses/'
    ,'http://dbs.uni-leipzig.de/de/study'
    ,'http://www.bioinf.uni-leipzig.de/teaching/currentClasses.html'
    ,'http://www.imise.uni-leipzig.de/Lehre/MedInf/Aktuelles.jsp'
    ,'http://www.informatik.uni-leipzig.de/~hlawit/vorlesungen.html'
  ]

  rules = [Rule(LinkExtractor(allow=['asv.informatik.uni-leipzig.de/courses/\d+'
                                    ,'www.informatik.uni-leipzig.de/ti/lehre/aktuellessemester/'
                                    ,'rvs.informatik.uni-leipzig.de/de/lehre/*/'
                                    ,'www.dh.uni-leipzig.de/wo/courses/*/'
                                     # todo: generalize semester
                                    ,'dbs.uni-leipzig.de/(stud/2014ws/|study/ws_2014_15/)'
                                    ,'http://www.bioinf.uni-leipzig.de/teaching/currentClasses/'
                                     # semester specific: 'http://www.imise.uni-leipzig.de/Lehre/Semester/2014-15/'
                                    ,'http://www.imise.uni-leipzig.de/Lehre/Semester/'
                                    ,'http://www.informatik.uni-leipzig.de/~hlawit/vorlesungen.html'
                                    ]
                              ), 'parse_course')]

  def parse_start_url(self, response):
    base_url = get_base_url(response)

    links = response.xpath('//a[@href]')
    items = set()
    for link in links:
      item = LinkingElement()
      item['linkurl'] = urljoin(base_url, link.xpath('@href')[0].extract())
      item['html_a'] = link.extract()
      print(item['linkurl'])
      print(item['html_a'])
      items.add(item)
    return items

  def parse_course(self, response):
    course = CourseItem()
    course['url'] = response.url
    course['html_title_text'] = response.xpath("//title/text()")[0].extract()
    course['html_body'] = response.xpath("//body")[0].extract()
    return course
