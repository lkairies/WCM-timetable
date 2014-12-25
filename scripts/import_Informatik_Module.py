#!/usr/bin/env python3
#################################
# vorraussetzungen: python3, pdfminer, python3-urllib3
#
import parse_bachelor, parse_master
import urllib.request
import os

current_modules_bachelor = \
'http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ba-inf/ba-inf-module.html'
current_modules_master = \
'http://www.informatik.uni-leipzig.de/ifi/studium/studiengnge/ma-inf/ma-inf-module.html'

testurl_bachelor = 'file:///home/joki/Studium/Master/WCM/WCM-timetable/scripts/test/ba-inf-module.pdf'
testurl_master = 'file:///home/joki/Studium/Master/WCM/WCM-timetable/scripts/test/ma-inf-module.pdf'

#TODO: use streams instead of files and put this into a function.
#~ r = urllib.request.urlopen(testurl_bachelor)
#~ with open('/tmp/ba-inf.pdf', 'wb') as f:
    #~ f.write(r.read())
#~ os.system('pdf2txt -o /tmp/a.out /tmp/ba-inf.pdf');
#~ bobj = open("/tmp/a.out", "r")


bobj = open("/home/joki/Studium/Master/WCM/WCM-timetable/scripts/test/ba-inf-module.txt", "r")
parse_bachelor.parse(bobj)


mobj = open("/home/joki/Studium/Master/WCM/WCM-timetable/scripts/test/ma-inf-module.txt", "r")
parse_master.parse(mobj)
