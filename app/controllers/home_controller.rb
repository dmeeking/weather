class HomeController < ApplicationController
  def index
  end

  def about
  end

  def temperature_readings

  	chartRange = 1.days.ago.midnight..-24.hours.ago
    chartRangePressure = 1.days.ago.midnight..Time.now
  	dateFormat = '%a, %d %b %Y %H:%M:%S %z';

    allReadings = WeatherReading.where(reading_at: chartRange).order(reading_at: :asc).select(:reading_at, :temperature, :pressure, :wind_speed, :wind_direction).to_a
    allReadings = allReadings.group_by_hour(format:dateFormat, default_value:nil) {|r| r.reading_at}

    forecastRange = WeatherReading.order(reading_at: :desc).limit(1).first.reading_at..-24.hours.ago
    allForecasts = HourlyForecast.where(reading_at: forecastRange).order(reading_at: :asc).select(:reading_at, :temperature, :wind_speed).to_a
    allForecasts = allForecasts.group_by_hour(format:dateFormat, default_value:nil) {|r| r.reading_at}

    render json: {
        observed: allReadings,
        forecast: allForecasts
      }
  end

  def degrees_from_direction(direction)
  	 directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
  	 index = directions.index(direction)
  	 index = index.nil? ? 0 : index
  	 
  	 11.5 + (index * 22.5)

  end


end
