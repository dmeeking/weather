class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	
  helper_method :current_conditions
  def current_conditions
  	temp = WeatherReading.where("temperature IS NOT NULL").order(reading_at: :desc).limit(1).pluck(:temperature).first
    wind = WeatherReading.where("wind_direction IS NOT NULL").order(reading_at: :desc).limit(1).pluck(:wind_speed, :wind_direction).first

    #return simple array with conditions
    [temp, wind[0], wind[1]]
  end


end
