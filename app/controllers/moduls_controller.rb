class ModulsController < ApplicationController
  def show
    @modul = Modul.where(nummer: params[:id]).first
  end

  def index
    @moduls = Modul.all
  end

  def json
    @moduls = Modul.all
    render json: @moduls
  end
end
