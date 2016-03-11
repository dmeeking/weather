class HomeController < ApplicationController
  def index
  end

  def about
  end

  def temperature_readings

  	render json: WeatherReading.group_by_hour(:reading_at, 
  		range:1.days.ago.midnight..Date.tomorrow.midnight, 
  		default_value:nil).average(:temperature)
  end

end
