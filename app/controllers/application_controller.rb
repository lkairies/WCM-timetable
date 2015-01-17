class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protected def selected_semester
    if params[:semester]
      return params[:semester]
    else
      #TODO: autodetect based on current date
      return "w14"
    end
  end
  helper_method :selected_semester
end
