class HomeController < ApplicationController
  def index
  end

  def about
  end

  def temperature_readings

  	chartRange = 1.days.ago.midnight..Date.tomorrow.tomorrow.midnight
  	forecastRange = Time.now..Date.tomorrow.tomorrow.midnight
  	dateFormat = '%a, %d %b %Y %H:%M:%S %z';

  	hourlyForecast = HourlyForecast.group_by_hour(:reading_at, format:dateFormat, range: forecastRange, default_value:nil).average(:temperature)
	windForecast = HourlyForecast.group_by_hour(:reading_at, format:dateFormat, range: forecastRange, default_value:nil).average(:wind_speed)

# Todo: Someday we can figure out how to return multiple aggregates in group_by
  	yowReadings = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).average(:temperature)
	windSpeed = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).average(:wind_speed)

  	highchartsData = {
  		yowReadings: yowReadings,
  		hourlyForecast: hourlyForecast,
  		windSpeed: windSpeed,
  		windSpeedForecast: windForecast
  	}

  	render json: highchartsData
  end

end
