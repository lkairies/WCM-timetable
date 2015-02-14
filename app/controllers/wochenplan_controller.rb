require 'icalendar'
require 'date'
require 'tzinfo'
class WochenplanController < ApplicationController

  LV_TIME_ZONE_STRING = 'Europe/Berlin'
  LV_TIME_ZONE = TZInfo::Timezone.get(LV_TIME_ZONE_STRING)

  def get_date_in_semester(semester, day, month)
    date = Date.new(year=semester.lvbegin.year, month=month, day=day)
    if date < semester.lvbegin
      date = Date.new(year=semester.lvend.year, month=month, day=day)
    end
    return date
  end

  def get_lv_events(lv)
    semester = Semester.find_by(semester_id: lv[:semester])
    lv_begin_date = semester.lvbegin
    lv_end_date = semester.lvend
    wd = lv["wochentag"]

    delimeters = Regexp.escape('- /')

    block = {}
    #detect 11.01./12.01.2014 (Blockveranstaltung)
    wd.match(/(?<sday>\d\d?)\.(?<smonth>\d\d?)\.[#{delimeters}](?<eday>\d\d?)\.(?<emonth>\d\d?)\.(?<eyear>\d\d\d\d)/) do |match|
      block = Hash[ match.names.zip(match.captures) ]
      block["syear"] = block["eyear"]
    end
    #detect 11./12.01.2014 (Blockveranstaltung)
    if block.empty?
      wd.match(/(?<sday>\d\d?)\.[#{delimeters}](?<eday>\d\d?)\.(?<emonth>\d\d?)\.(?<eyear>\d\d\d\d)/) do |match|
        block = Hash[ match.names.zip(match.captures) ]
        block["smonth"] = block["emonth"]
        block["syear"] = block["eyear"]
      end
    end
    #detect vom 09.12.2014 bis 19.01.2015 täglich
    wd.match(/(?<sday>\d\d?)\.(?<smonth>\d\d?)\.(?<syear>\d\d\d\d) bis (?<eday>\d\d?)\.(?<emonth>\d\d?)\.(?<eyear>\d\d\d\d)/) do |match|
      block = Hash[ match.names.zip(match.captures) ]
    end
    unless block.empty?
      block.each do |key, value|
        block[key] = value.to_i
      end
      #logger.debug "block: #{block.inspect}"
      lv_begin_date = Date.new(year=block["syear"], month=block["smonth"], day=block["sday"])
      lv_end_date = Date.new(year=block["eyear"], month=block["emonth"], day=block["eday"])
    end

    #detect donnerstags (A-Woche, ab 13.11.)
    if block.empty?
      block = wd.scan(/ab (\d\d?)\.(\d\d?)\./)[0]
      if block
        start_day = block[0].to_i
        start_month = block[1].to_i
        lv_begin_date = get_date_in_semester(semester, start_day, start_month)
      end
    end

    # possible patterns:
    # 11./12.01.2014 (Blockveranstaltung)
    # 30.06.-11.07.2014
    # 14.-25.07.2014
    # Blockveranstaltung 20./21.6.2014
    # dienstags (ab 4.11.)
    # 05.01. 09.01.2015
    # donnerstags (A-Woche, ab 13.11.)
    # vom 09.12.2014 bis 19.01.2015 täglich
    # ZL
    # ZF
    #TODO: what does "ZL" mean? or "ZF"?

    event_has_weekday = false
    # ruby Date.wday begins the week at sunday
    weekdays = {1 => "montags", 2 => "dienstags", 3 => "mittwochs", 4 => "donnerstags", 5 => "freitags", 6 => "samstags" }
    #logger.debug "weekday: #{wd}"
    week = {:a => [false, false, false, false, false, false, false], :b => [false, false, false, false, false, false, false]}
    if wd.include? "täglich"
      event_has_weekday = true
      week[:a] = [false, true, true, true, true, true, true]
      week[:b] = [false, true, true, true, true, true, true]
    end

    a = (wd.include? "A-Woche")
    b = (wd.include? "B-Woche")

    weekdays.each do |n, day|
      if wd.include? day
        event_has_weekday = true
        if a == true and b == false
          week[:a][n] = true
        elsif b == true and a == false
          week[:b][n] = true
        else
          week[:a][n] = true
          week[:b][n] = true
        end
      end
    end

    unless event_has_weekday
      week[:a] = [true, true, true, true, true, true, true]
      week[:b] = [true, true, true, true, true, true, true]
    end

    lv_start_time = {}
    lv_end_time = {}

    if lv[:zeit_von] and lv[:zeit_bis]
      # lv_start and lv_end contain the time information for the lv. the array contains hours and minutes.
      lv_start = lv["zeit_von"].split(":")
      lv_start_time[:hours] = lv_start[0].to_i
      lv_start_time[:minutes] = lv_start[1].to_i
      lv_end = lv["zeit_bis"].split(":")
      lv_end_time[:hours] = lv_end[0].to_i
      lv_end_time[:minutes] = lv_end[1].to_i
    # end
    else
      lv_start_time = { :hours => 7, :minutes => 0}
      lv_end_time = { :hours => 21, :minutes => 0}
    end
    #logger.debug "dozent: #{lv[:dozent]}"

    events = Array.new
    semester[:vorlesungstage].each do |day|
      date = semester.lvbegin + day
      next if (date < lv_begin_date) or (date > lv_end_date)

      #logger.debug "Date: #{date}"
      #specification says: "Die A-Woche bezieht sich dabei auf die ungeraden Kalenderwochen und die B-Woche auf die geraden Kalenderwochen."
      current_week = (date.cweek % 2 == 1) ? :a : :b
      if week[current_week][(day+semester.lvbegin.wday)%7]
        event = Icalendar::Event.new

        if lv_start_time.empty?
          # TODO: currently unused code. when there is no time specified for an event, make it a day event.
          # Currently we are using a hardcoded time in this case (7-21 hours),
          # because the json renderer demands it this way. the json renderer is used by the jquery-week-calendar.
          event.dtstart = date
          event.dtstart.ical_params = { "VALUE" => "DATE" }
          event.dtend = date
          event.dtend.ical_params = { "VALUE" => "DATE" }
        else
          dtstart = DateTime.new(year=date.year, month=date.month, day=date.day, hours=lv_start_time[:hours], minutes=lv_start_time[:minutes])
          event.dtstart = Icalendar::Values::DateTime.new dtstart, 'tzid' => LV_TIME_ZONE_STRING
          #logger.debug "dtstart :: #{dtstart} :: #{dtstart.inspect} :: #{dtstart.to_s}"
          #logger.debug "e.dtstart: #{event.dtstart.inspect}"
          dtend = DateTime.new(year=date.year, month=date.month, day=date.day, hours=lv_end_time[:hours], minutes=lv_end_time[:minutes])
          event.dtend = Icalendar::Values::DateTime.new dtend, 'tzid' => LV_TIME_ZONE_STRING
        end
        event.summary = lv["titel"]
        event.location = lv[:raum]
        # organizer field requires an uri (can be an email address) (https://tools.ietf.org/html/rfc5545#section-3.3.3)
        #event.organizer = lv[:dozent]
        event.description = "Titel: #{lv[:titel]}\n\n"
        event.description += "Dozenten:\n"
        lv[:dozent].each do |dozent|
          event.description += "#{dozent}\n"
        end
        event.description += "\n"+
          #{lv[:dozent].split(";")}\n\n"+
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
    require 'icalendar/tzinfo'
    @icalendar = Icalendar::Calendar.new
    timezone = LV_TIME_ZONE.ical_timezone DateTime.now
    @icalendar.add_timezone timezone

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
    @semester = Semester.find_by(semester_id: selected_semester)
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
