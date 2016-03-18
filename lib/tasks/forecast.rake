namespace :forecast do
  desc "Scrape recent conditions from environment canada for YOW"
  task :scrape => :environment do

		now = Time.now.in_time_zone.strftime('%A @ %r')
		begin
      readings = WeatherReading.gather_web_weather
			forecasts = HourlyForecast.gather_web_forecast
			alerts = WeatherAlert.gather_alerts
			PushNotification.create_send(PushNotification::ADMIN_ERRORS, "Forecasts Updated Successfully", "Scraped at #{now}. #{readings} readings | #{forecasts} forecasts | #{alerts} alerts")
		rescue Exception => e
			PushNotification.create_send(PushNotification::ADMIN_ALL, "Forecast Update Error", "Forecast scrape error: #{e.message} at #{now}" )
		end
  end

	desc "Scrape recent condition from Wunderground"
	task :local => :environment do

		now = Time.now.in_time_zone.strftime('%A @ %r')
		begin

			local_readings = WeatherReading.gather_local_weather
			PushNotification.create_send(PushNotification::ADMIN_ERRORS, "Local Conditions Updated Successfully", "Scraped at #{now}. #{local_readings} readings")
		rescue Exception => e
			PushNotification.create_send(PushNotification::ADMIN_ALL, "Locao conditions update error", "Local weather gathering error: #{e.message} at #{now}" )
		end
	end

end