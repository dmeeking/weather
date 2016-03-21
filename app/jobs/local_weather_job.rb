class LocalWeatherJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

      now = Time.now.in_time_zone.strftime('%A @ %r')
      begin

        local_readings = WeatherReading.gather_local_weather
        PushNotification.create_send(PushNotification::ADMIN_ALL, "Local Conditions Updated Successfully", "Scraped at #{now}. #{local_readings} readings")
      rescue Exception => e
        PushNotification.create_send(PushNotification::ADMIN_ERRORS, "Locao conditions update error", "Local weather gathering error: #{e.message} at #{now}" )
      end

  end
end
