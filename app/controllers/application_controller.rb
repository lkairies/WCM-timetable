class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # this method returns the currently selected semester.
  # if no semester was selected, it uses the current date to determine
  # which semester the user probably wants to select.
  # the upcoming semester is selected when there are no more future
  # events in the current semester.
  protected def selected_semester
    unless params[:semester] and params[:semester] != ''
      #fallback value, because we don't really trust our database
      params[:semester] = "w14"

      require 'date'
      today = Date.today
      Semester.order(:lvend).each do |semester|
        if today <= semester[:lvend]
          params[:semester] = semester[:semester_id]
          break
        end
      end
    end
    return params[:semester]
  end
  helper_method :selected_semester
end
