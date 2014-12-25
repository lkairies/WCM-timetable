#!/usr/bin/env python3
import os, sys, re

def parse(pdf2txt_stream):
    fobj = pdf2txt_stream
    department = 'Institut für Informatik'

    counter=0
    counter2 =0
    founddate=0

    index=1
    flag=0
    flagInhalt=0
    flagInhaltException=0

    liste = []
    liste2 = []
    titles =[]
    numbers=[]

    letzteZeile='leer'

    title=''
    lp='0'
    inhalt=''
    modultype=''

    for line in fobj:
        liste.insert(counter, line)
        counter+=1

        #modulnummer
        if counter==1:
            number=line

        #Leistungspunkte
        if '5 LP = 150 Arbeitsstunden (Workload)' in line:index+=1; lp=5
        if '10 LP = 300 Arbeitsstunden (Workload)' in line:index+=1; lp=10

        #modultitel bachelor

        #inhalt
        if line.strip() == 'Teilnahmevoraus-':
            flagInhalt=0
            if inhalt.strip()=='':
                #print 'fehler'+number
                flagInhaltException=1
                 #inhalt steht dann zwischen 'Literaturangabe' und 'keine'

        if flagInhalt==1: inhalt += line
        if line.strip() =='Inhalt': flagInhalt=1


        #inhalt Ausnahmebehandlung
        if line.strip() == 'keine': flagInhaltException=0
        if flagInhaltException==2: inhalt += line
        if line.strip() =='Literaturangabe' and flagInhaltException==1: flagInhaltException=2

        letzteZeile=line

        #str = line
        match = re.search(r'\d\d?\.\s\w+\s\d{4}', line)
        # If-statement after search() tests if it succeeded
        #if match:
            #print 'found', match.group() ## 'found word:cat'
            #founddate+=1
            #print founddate

        if 'Vertiefungsmodul'==line.strip(): modultype='Vertiefungsmodul'
        if 'Ergänzungsfach'==line.strip(): modultype='Ergänzungsfach'
        if 'Kernmodul'==line.strip(): modultype='Kernmodul'
        if 'Seminarmodul'==line.strip(): modultype='Seminarmodul'
        if 'Ergänzungsfach Medizinische Informatik'==line.strip(): modultype='Ergänzungsfach Medizinische Informatik'


        #neuer eintrag
        if 'Modulnummer' in line:
            flag+=1

            if title.strip()=='Wahrscheinlichkeitstheorie':
                inhalt='Einführung in die Denkweisen und Beweismethoden der W\'theorie, Erschließung wichtiger Einsatz- und Anwendungsgebiete der Mathematik diskrete Wahrscheinlichkeitsräume und Wahrscheinlichkeiten mit Dichten: grundlegende Konzepte (Erwartungswert, Varianz, Unabhängigkeit, Zufallsgrößen), Beispiele für Verteilungen, Gesetz der Großen Zahlen, Satz von Moivre-Laplace, einführende Betrachtungen der mathematischen Statistik (Schätztheorie, Konfidenzbereiche, Testtheorie)'

            counter=0
            liste2=liste
            liste[:]=[]
            #print title
            if counter2>0:
                titles.append(title.strip() )
                numbers.append(number.strip())
                #print titles[counter2-1]+numbers[counter2-1]
            counter2+=1

            #~ type, created = ModulType.objects.get_or_create(name=modultype)
            #~ modul, created = Modul.objects.get_or_create(number=number.strip())
            #~ if created or not modul.name:
                #~ modul.name = title.strip()
            #~ modul.lp=lp
            #~ modul.modultype=type
            #~ modul.description=inhalt
            #~ modul.department = department
            #~ modul.save()
            print("Abteilung: ", department)
            print("Name: ", title.strip())
            print("LP: ", lp)
            print("Modultyp: ", modultype)
            print("Beschreibung: ", len(inhalt))





            title=''
            number=''
            lp='0'
            inhalt=''
            modultype=''

    fobj.close()
