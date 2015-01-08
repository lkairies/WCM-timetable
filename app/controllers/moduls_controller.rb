class ModulsController < ApplicationController
  def show
    @modul = Modul.where(nummer: params[:id]).first
    #does Hash.new( Array.new ) work? New array as default Hash value.
    @lvs = Hash.new
    Lehrveranstaltung.where(modul_id: @modul.nummer).each do |lv|
      unless @lvs.has_key?(lv.titel)
        lvlist = Array.new
        @lvs[lv.titel]=lvlist
      end
      @lvs[lv.titel].push(lv)
    end
  end

  def index
    @moduls = Modul.all
    @modul_lvs = Hash.new
    Lehrveranstaltung.all.each do |lv|
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
