class ModulsController < ApplicationController
  def show
    @modul = Modul.where(nummer: params[:id]).first
  end

  def list
    @moduls = Modul.all
  end
end
