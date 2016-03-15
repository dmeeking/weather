namespace :forecast do
  desc "Scrape recent conditions from environment canada for YOW"
  task :scrape => :environment do
  	
	now = Time.now.strftime('%A @ %r')
  	begin
	  	WeatherReading.gather_web_weather
		HourlyForecast.gather_web_forecast
		WeatherAlert.gather_alerts

		#PushNotification.create_send('admin_all', "Forecasts Updated Successfully", "Scraping succeeded at #{now}")
	rescue Exception => e
		PushNotification.create_send('admin_all', "Forecast Update Error", "Forecast scrape error: #{e.message} at #{now}" )
	end
  end

end