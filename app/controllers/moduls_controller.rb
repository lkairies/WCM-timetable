class ModulsController < ApplicationController
  def show
  end

  def list
    @moduls = Modul.all
  end
end
