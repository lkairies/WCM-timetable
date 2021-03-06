# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class LinkingElement(scrapy.Item):
  linkurl = scrapy.Field()
  html_a = scrapy.Field()

class CourseItem(scrapy.Item):
  url = scrapy.Field()
  html_title_text = scrapy.Field()
  html_body = scrapy.Field()
