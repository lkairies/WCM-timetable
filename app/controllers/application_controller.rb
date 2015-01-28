class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protected def selected_semester
    if params[:semester] and params[:semester] != ''
      return params[:semester]
    else
      require 'date'
      today = Date.today
      Semester.all.each do |semester|
        if semester[:begin] < today and today < semester[:end]
          return semester[:semester_id]
        end
      end
    end
  end
  helper_method :selected_semester
end
