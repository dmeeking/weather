class HomeController < ApplicationController
  def index
  end

  def about
  end

  def temperature_readings

 # 	chartRange = 1.days.ago.midnight..Date.tomorrow.tomorrow.midnight
  	chartRange = 1.days.ago.midnight..-23.hours.ago
  	dateFormat = '%a, %d %b %Y %H:%M:%S %z';

# Todo: Someday we can figure out how to return multiple aggregates in group_by
  	yowReadings = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).average(:temperature)
	  windSpeed = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).average(:wind_speed)
	#windDirection = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).minimum(:wind_direction)

    forecastRange = WeatherReading.order(reading_at: :desc).limit(1).first.reading_at..-23.hours.ago
  
    hourlyForecast = HourlyForecast.group_by_hour(:reading_at, format:dateFormat, range: forecastRange, default_value:nil).average(:temperature)
    windForecast = HourlyForecast.group_by_hour(:reading_at, format:dateFormat, range: forecastRange, default_value:nil).average(:wind_speed)


  	highchartsData = {
  		yowReadings: yowReadings,
  		hourlyForecast: hourlyForecast,
  		windSpeed: windSpeed,
  		windSpeedForecast: windForecast,
  		#windDirection: ar2
  	}

  	render json: highchartsData
  end

  def degrees_from_direction(direction)
  	 directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
  	 index = directions.index(direction)
  	 index = index.nil? ? 0 : index
  	 
  	 11.5 + (index * 22.5)

  end


end
