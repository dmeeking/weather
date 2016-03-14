class ScrapeWeatherJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    
  	WeatherReading.gather_web_weather
	HourlyForecast.gather_web_forecast
	WeatherAlert.gather_alerts

  end
end
