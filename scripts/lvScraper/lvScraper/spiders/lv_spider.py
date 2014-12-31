import scrapy

#from scrapy import Spider, Item, Field
from scrapy.contrib.spiders import CrawlSpider, Rule
from scrapy.contrib.linkextractors import LinkExtractor

class ASVSpider(CrawlSpider):
  name = 'lv'
  allowed_domains = ['www.informatik.uni-leipzig.de', 'asv.informatik.uni-leipzig.de', 'rvs.informatik.uni-leipzig.de', 'www.dh.uni-leipzig.de']
  start_urls = ['http://asv.informatik.uni-leipzig.de/courses/', 'http://www.informatik.uni-leipzig.de/ti/lehre/aktuellessemester.html', 'http://rvs.informatik.uni-leipzig.de/de/lehre/', 'http://www.dh.uni-leipzig.de/wo/courses/']
  rules = [Rule(LinkExtractor(allow=['asv.informatik.uni-leipzig.de/courses/\d+', 'www.informatik.uni-leipzig.de/ti/lehre/aktuellessemester/', 'rvs.informatik.uni-leipzig.de/de/lehre/*/', 'www.dh.uni-leipzig.de/wo/courses/*/']), 'parse_course')]

  def parse_course(self, response):
    course = CourseItem()
    course['url'] = response.url
    course['html_title_text'] = response.xpath("//title/text()")[0].extract()
    course['html_body'] = response.xpath("//body")[0].extract()
    return course
