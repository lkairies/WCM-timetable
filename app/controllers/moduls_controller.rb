class ModulsController < ApplicationController
  def show
    #todo: automatically detect this!
    current_semester = "w14"
    @modul = Modul.where(nummer: params[:id]).first
    #does Hash.new( Array.new ) work? New array as default Hash value.
    @lvs = Hash.new
    Lehrveranstaltung.where(modul_id: @modul.nummer).where( semester: current_semester ).each do |lv|
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
    db_moduls = Modul.where( nummer: modnums )
    @moduls = Hash.new
    db_moduls.each do |m|
      @moduls[m.nummer] = m
    end
    @modul_lvs = Hash.new
    Lehrveranstaltung.where( modul_id: modnums ).where( semester: current_semester ).each do |lv|
      unless @modul_lvs.has_key?(lv.modul_id)
        lvlist = Array.new
        @modul_lvs[lv.modul_id]=lvlist
      end
      unless @modul_lvs[lv.modul_id].include?(lv.titel)
        @modul_lvs[lv.modul_id].push(lv.titel)
      end
    end
  end
end
