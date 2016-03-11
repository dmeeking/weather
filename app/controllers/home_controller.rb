class HomeController < ApplicationController
  def index
  end

  def about
  end

  def temperature_readings

  	chartRange = 1.days.ago.midnight..Date.tomorrow.tomorrow.midnight
  	forecastRange = Time.now..Date.tomorrow.tomorrow.midnight
  	dateFormat = '%a, %d %b %Y %H:%M:%S %z';
  	yowReadings = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).average(:temperature)
	hourlyForecast = HourlyForecast.group_by_hour(:reading_at, format:dateFormat, range: forecastRange, default_value:nil).average(:temperature)

  	highchartsData = {
  		yowReadings: yowReadings,
  		hourlyForecast: hourlyForecast
  	}

  	render json: highchartsData
  end

end
