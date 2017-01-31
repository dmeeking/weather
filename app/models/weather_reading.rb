class WeatherReading < ActiveRecord::Base
	include WeatherReadingValidations
	after_initialize :init

    def init
      	self.temperature # ||= 0.0           #will set the default value only if it's nil
      	self.pressure  ||= 0.0           #will set the default value only if it's nil
		    self.wind_speed  ||= 0.0           #will set the default value only if it's nil
    end

# called by a rake task that is scheduled to run every hour
  def self.gather_web_weather
      weather_count = 0
      require 'open-uri'
      url = "https://weather.gc.ca/past_conditions/index_e.html?station=yow"
      doc = Nokogiri::HTML(open(url))
      currentDate = Date.today
      timeOffset = Time.zone.now.formatted_offset

      doc.css("tbody tr").each do |item|
        if date = item.at_css('th')
          currentDate = date.text;
        else


          time = item.at_css('td[headers="header1"]').text
          temperature = item.at_css('td[headers="header3m"]').text.split("\u{00A0}")[0]#.gsub!(/\W-/,'') # it's a non-breaking space, not a regular space
          wind = item.at_css('td[headers="header4m"]').text.split(" ") 
          wind_dir = wind[0].strip
          wind_speed = wind[1]
          humidity = item.at_css('td[headers="header7"]').text
          dew_point = item.at_css('td[headers="header8"]').text
          pressure = item.at_css('td[headers="header9m"]').text
          historicalDateTime = DateTime.parse("#{currentDate} #{time} #{timeOffset}")
         # puts "#{Time.zone} #{historicalDateTime} -#{wind_dir} - #{wind_speed} - #{pressure}"


          reading = WeatherReading.where(location: 'YOW', reading_at: historicalDateTime.utc).first_or_initialize
          if reading.new_record?
            weather_count = weather_count + 1
          end
          reading.location = 'YOW'
          reading.temperature = temperature
          reading.wind_speed = wind_speed
          reading.wind_direction = wind_dir
          reading.pressure = pressure
          reading.dew_point = dew_point
          reading.relative_humidity = humidity


          reading.save! #throw an exception if there are validation errors
          
        end

      end

      # delete older than 1mo
      WeatherReading.delete_all("reading_at < '#{30.days.ago}'")

      weather_count
  end


# called by a rake task that is scheduled to run 5 minutes or so hour
  def self.gather_local_weather
    weather_count = 0
    require 'open-uri'
    api_key = Rails.application.secrets.wunderground_key

    url = "http://api.wunderground.com/api/#{api_key}/conditions/q/pws:IONOTTAW40.json"
    conditions = JSON.parse(open(url).read)
    if conditions.nil?
      return 0
    end

    observation = conditions['current_observation']
    temperature = observation['temp_c']
    wind_dir = nil
    wind_speed = nil
    humidity = observation['relative_humidity']
    dew_point = observation['dewpoint_c']
    pressure = observation['pressure_mb'].to_i / 10.0
    historicalDateTime = DateTime.parse(observation['observation_time_rfc822'])
    # puts "#{historicalDateTime} -#{wind_dir} - #{wind_speed} - #{pressure}"


    reading = WeatherReading.where(location: 'WBO', reading_at: historicalDateTime.utc).first_or_initialize
    if reading.new_record?
      weather_count = weather_count + 1
    end
    reading.location = 'WBO'
    reading.temperature = temperature
    reading.wind_speed = wind_speed
    reading.wind_direction = wind_dir
    reading.pressure = pressure
    reading.dew_point = dew_point
    reading.relative_humidity = humidity
    reading.save! #throw an exception if there are validation errors


    # delete older than 1mo
    WeatherReading.delete_all("reading_at < '#{30.days.ago}'")

    weather_count
  end

end
