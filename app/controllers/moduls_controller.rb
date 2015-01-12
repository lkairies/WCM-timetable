class ModulsController < ApplicationController
  def show
    #todo: automatically detect this!
    current_semester = "w14"
    @modul = Modul.where(modul_id: params[:id]).first
    #does Hash.new( Array.new ) work? New array as default Hash value.
    @lvs = Hash.new
    Lehrveranstaltung.where(modul_id: @modul.modul_id).where( semester: current_semester ).each do |lv|
      unless @lvs.has_key?(lv.titel)
        lvlist = Array.new
        @lvs[lv.titel]=lvlist
      end
      @lvs[lv.titel].push(lv)
    end
  end

  # @studiengaenge is an array of strings
  # @moduls is a hash with all moduls from the database
  # @modul_lvs is a hash with a list of lvs for each modul.
  #  only moduls that are referenced by an lv are included.
  # keys for the hashes are the modulnummers.
  def index
    #todo: automatically detect this!
    current_semester = "w14"
    # TODO: maybe there is a method "to_array"?
    @studiengaenge = Array.new
    StudiengangModul.select(:studiengang).distinct.each do |sg|
      @studiengaenge.push(sg.studiengang)
    end
    if params[:studiengang]
      modnums = StudiengangModul.where( studiengang: params[:studiengang] ).select(:modul_id)
    else
      modnums = StudiengangModul.select(:modul_id)
    end
    logger.debug "Modnums: #{modnums.inspect}"
    db_moduls = Modul.where( modul_id: modnums )
    @moduls = Hash.new
    db_moduls.each do |m|
      @moduls[m.modul_id] = m
    end
    @modul_lvs = Hash.new
    Lehrveranstaltung.where( modul_id: modnums ).where( semester: current_semester ).each do |lv|
      unless @modul_lvs.has_key?(lv.modul_id)
        lvlist = Hash.new
        @modul_lvs[lv.modul_id]=lvlist
      end
      unless @modul_lvs[lv.modul_id].has_key?(lv.titel)
        #TODO: this will only reference the first lv, if there are multiple lvs with the same name.
        @modul_lvs[lv.modul_id][lv.titel] = lv.lv_id
      end
    end
  end
end
