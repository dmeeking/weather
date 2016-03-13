class HomeController < ApplicationController
  def index
  end

  def about
  end

  def temperature_readings

  	chartRange = 1.days.ago.midnight..-23.hours.ago
    chartRangePressure = 1.days.ago.midnight..Time.now
  	dateFormat = '%a, %d %b %Y %H:%M:%S %z';

   # Works! Will require some (easy) refactoring of client-side code to make it work fully
   # allReadings = WeatherReading.where(reading_at: chartRange).order(reading_at: :asc).select(:reading_at, :temperature, :pressure, :wind_speed, :wind_direction).to_a
   # allReadings = allReadings.group_by_hour(format:dateFormat, default_value:nil) {|r| r.reading_at}

  	yowReadings = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).average(:temperature)
	  windSpeed = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).average(:wind_speed)
    pressureReadings = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRangePressure, default_value:nil).average(:pressure)
	  windDirection = WeatherReading.group_by_hour(:reading_at, format:dateFormat, range: chartRange, default_value:nil).minimum(:wind_direction)

    forecastRange = WeatherReading.order(reading_at: :desc).limit(1).first.reading_at..-23.hours.ago
  
    hourlyForecast = HourlyForecast.group_by_hour(:reading_at, format:dateFormat, range: forecastRange, default_value:nil).average(:temperature)
    windForecast = HourlyForecast.group_by_hour(:reading_at, format:dateFormat, range: forecastRange, default_value:nil).average(:wind_speed)




  	highchartsData = {
  		yowReadings: yowReadings,
  		hourlyForecast: hourlyForecast,
  		windSpeed: windSpeed,
  		windSpeedForecast: windForecast,
      pressureReadings: pressureReadings
  		#windDirection: ar2
  	}

  	render json: highchartsData

    #render json: {
     #   observed: allReadings,
     #   forecast: TODO
     # }
  end

  def degrees_from_direction(direction)
  	 directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
  	 index = directions.index(direction)
  	 index = index.nil? ? 0 : index
  	 
  	 11.5 + (index * 22.5)

  end


end
