class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	
  helper_method :current_conditions
  def current_conditions
  	WeatherReading.order(reading_at: :desc).pluck(:temperature, :wind_speed, :wind_direction).first
  	
  end


end
