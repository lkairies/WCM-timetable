require 'icalendar'
require 'date'
class WochenplanController < ApplicationController
  def get_vorlesungstage(semester_begin, semester_end)

    vorlesungstage = Array(0..(semester_end-semester_begin))
    logger.debug "vorlesungstage (roh): #{vorlesungstage}"


    #TODO: filter events by free days: https://www.zv.uni-leipzig.de/studium/studienorganisation/akademisches-jahr.html
    vorlesungsfrei = ["31.10.2014 (Freitag) vorlesungsfrei", "19.11.2014 (Mittwoch) vorlesungsfrei", "vom 21.12.2014 bis 04.01.2015 vorlesungsfrei"]

    vorlesungsfrei.each do |str|
      if str.include? "vorlesungsfrei"
        logger.debug "break: #{str}"
        if str.include? " bis "
          dates = str.split(" bis ")
          break_begin = Date.parse(dates[0])
          break_end = Date.parse(dates[1])+1 # add one because the end of break date is included in the break
          logger.debug "from #{break_begin}   to #{break_end}   -   length: #{break_end-break_begin}"
          vorlesungstage -= Array((break_begin-semester_begin).to_i..(break_end-semester_begin).to_i)
        else
          break_date = Date.parse(str)
          logger.debug "at: #{break_date}"
          vorlesungstage -= [(break_date-semester_begin).to_i]
        end
      end
    end
    logger.debug "vorlesungstage (reduziert): #{vorlesungstage}"
    return vorlesungstage

  end

  def get_lv_events(lv)
    events = Array.new
    unless lv[:zeit_von]
      return events
    end
    semester_begin = Date.parse("2014-10-13")
    semester_end = Date.parse("2015-02-07")

    #TODO: decode pattern:
    # 11./12.01.2014 (Blockveranstaltung)
    # 30.06.-11.07.2014
    # 14.-25.07.2014
    # Blockveranstaltung 20./21.6.2014
    # dienstags (ab 4.11.)
    # 05.01. 09.01.2015
    # donnerstags (A-Woche, ab 13.11.)
    # vom 09.12.2014 bis 19.01.2015 täglich
    #TODO: what does "ZL" mean?
    # ZL

    # ruby Date.wday begins the week at sunday
    weekdays = {1 => "montags", 2 => "dienstags", 3 => "mittwochs", 4 => "donnerstags", 5 => "freitags", 6 => "samstags" }
    wd = lv["wochentag"]
    logger.debug "weekday: #{wd}"
    doubleweek = [false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    if wd.include? "täglich"
      doubleweek = [false, true, true, true, true, true, true, false, true, true, true, true, true, true]
    end



    a_week = (wd.include? "A-Woche")
    b_week = (wd.include? "B-Woche")

    weekdays.each do |n, day|
      if wd.include? day
        if a_week == true and b_week == false
          doubleweek[n] = true
        elsif b_week == true and a_week == false
          doubleweek[n+7] = true
        else
          doubleweek[n] = true
          doubleweek[n+7] = true
        end
      end
    end

    # lvStart and lvEnd contain the time information for the lv. the array contains hours and minutes.
    lv_start = lv["zeit_von"].split(":")
    start_hours = lv_start[0].to_i
    start_minutes = lv_start[1].to_i
    lv_end = lv["zeit_bis"].split(":")
    end_hours = lv_end[0].to_i
    end_minutes = lv_end[1].to_i

    logger.debug "dozent: #{lv[:dozent]}"

    get_vorlesungstage(semester_begin, semester_end).each do |day|
      if doubleweek[(day+semester_begin.wday)%14]
        date = semester_begin + day
        event = Icalendar::Event.new
        event.dtstart = DateTime.new(date.year, date.month, date.day, start_hours, start_minutes)
        event.dtend = DateTime.new(date.year, date.month, date.day, end_hours, end_minutes)
        event.summary = lv["titel"]
        event.location = lv[:raum]
        # organizer field requires an email address (https://www.ietf.org/rfc/rfc2445.txt)
        #event.organizer = lv[:dozent]
        event.description = "Titel: #{lv[:titel]}\n\n"+
          "Dozent(en): #{lv[:dozent].split(";")}\n\n"+
          "Lehrform: #{lv[:form]}\n\n"+
          "Modul: #{lv[:modul_id]}\n\n"+
          "Terminregel: #{lv[:wochentag]}"

        events.push(event)
      end
    end

    return events

  end


  def index


    @icalendar = Icalendar::Calendar.new
    url_lvs = params[:lvs]
    logger.debug "lvs: #{url_lvs.inspect}"
    array = url_lvs.split(",")
    logger.debug "decoded: #{array.inspect}"
    array.each do |lv_id|
      lv = Lehrveranstaltung.where(lv_id: lv_id).where(semester: selected_semester).first
      logger.debug "selected: #{lv.inspect}"
      get_lv_events(lv).each do |e|
        @icalendar.add_event(e)
      end
    end
    @icalendar.publish


    respond_to do |wants|
      wants.ics do
        render :text => @icalendar.to_ical
      end
      wants.html
    end

  end
end
