class HomeController < ApplicationController
  def index
    require 'open-uri'
    alerts_url = 'https://weather.gc.ca/rss/warning/on-118_e.xml'
    doc = Nokogiri::HTML(open(alerts_url))
    entry = doc.css("entry")

     # currentDate = Date.today
     # doc.css("tbody tr").each do |item|
     #   if date = item.at_css('th')
     #     currentDate = date.text;
    @test = entry
    @has_alert = entry.length > 0
    if @has_alert

      @alert_summary =entry.css('summary').text
      if @alert_summary == 'No watches or warnings in effect.'
        @has_alert =false
      else
        @alert_url = entry.css('link')[0]['href']
        @alert_title = entry.css('title').text
      end
    end
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
        forecast: allForecasts,
        windDirections: wind_direction_map
      }
  end

  # returns a numerical mapping of text directions to degrees
  def wind_direction_map
    wind_directions = ["NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"];
    magic_map = {

    }
    wind_directions.each_with_index { |x, index| 
        magic_map[x] = (index+1) * 22.5
     }
    magic_map
  end



end
