require 'icalendar'
require 'date'
require 'tzinfo'
class WochenplanController < ApplicationController

  def get_lv_events(lv)
    events = Array.new
    unless lv[:zeit_von]
      return events
    end
    semester = Semester.find_by(semester_id: lv[:semester])

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
    #logger.debug "weekday: #{wd}"
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

    #logger.debug "dozent: #{lv[:dozent]}"

    #TODO: use a configurable parameter for this:
    lv_time_zone = TZInfo::Timezone.get('Europe/Berlin')

    semester[:vorlesungstage].each do |day|
      if doubleweek[(day+semester.begin.wday)%14]
        date = semester.begin + day
        event = Icalendar::Event.new

        # the naming of time functions is very confusing, please read the documentation of tzinfo
        lvstart = lv_time_zone.local_to_utc(Time.utc(date.year, date.month, date.day, start_hours, start_minutes))
        lvend = lv_time_zone.local_to_utc(Time.utc(date.year, date.month, date.day, end_hours, end_minutes))

        event.dtstart = DateTime.parse(lvstart.to_s)
        event.dtend = DateTime.parse(lvend.to_s)
        event.summary = lv["titel"]
        event.location = lv[:raum]
        # organizer field requires an uri (can be an email address) (https://tools.ietf.org/html/rfc5545#section-3.3.3)
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

  private def get_lvs
    lvs = []
    if params[:lvs]
      #logger.debug "lvs: #{params[:lvs].inspect}"
      lvs = params[:lvs].split(",")
    end
    return lvs
  end

  private def generate_ics
    @icalendar = Icalendar::Calendar.new
    get_lvs.each do |lv_id|
      lv = Lehrveranstaltung.where(lv_id: lv_id).where(semester: selected_semester).first
      #logger.debug "selected: #{lv.inspect}"
      get_lv_events(lv).each do |e|
        @icalendar.add_event(e)
      end
    end
  end

  private def render_ics
    generate_ics
    @icalendar.publish
    @icalendar.to_ical
  end

  private def render_json
    events = []
    get_lvs.each do |lv_id|
      lv = Lehrveranstaltung.where(lv_id: lv_id).where(semester: selected_semester).first
      #logger.debug "selected: #{lv.inspect}"
      get_lv_events(lv).each do |ical_event|
        event = {}
        event["id"] = ical_event.uid
        event["title"] = ical_event.summary
        event["start"] = ical_event.dtstart
        event["end"] = ical_event.dtend
        events.push(event)
      end
    end
    result = { :events => events }
    return result
  end

  private def render_html
    params[:start_date] = '2014-10-13'
    @host = request.host
    @icalendar = Icalendar::Calendar.new
    url_lvs = params[:lvs]
    #logger.debug "lvs: #{url_lvs.inspect}"
    array = url_lvs.split(",")
    #logger.debug "decoded: #{array.inspect}"
    array.each do |lv_id|
      lv = Lehrveranstaltung.where(lv_id: lv_id).where(semester: selected_semester).first
      #logger.debug "selected: #{lv.inspect}"
      get_lv_events(lv).each do |e|
        @icalendar.add_event(e)
      end
    end
    @icalendar.publish
  end

  def index
    respond_to do |format|
      format.json do
        render :json => render_json
      end
      format.ics do
        render :text => render_ics
      end
      format.html do
        render_html
      end
    end
  end
end
