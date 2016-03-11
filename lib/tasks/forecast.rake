namespace :forecast do
  desc "Scrape recent conditions from environment canada for YOW"
  task :scrape => :environment do
  	WeatherReading.gather_web_weather
	HourlyForecast.gather_web_forecast

  end

end