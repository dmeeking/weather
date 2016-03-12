class WeatherReading < ActiveRecord::Base
	include WeatherReadingValidations
	after_initialize :init

    def init
      	self.temperature  ||= 0.0           #will set the default value only if it's nil
      	self.pressure  ||= 0.0           #will set the default value only if it's nil
		    self.wind_speed  ||= 0.0           #will set the default value only if it's nil
    end

# called by a rake task that is scheduled to run every hour
  def self.gather_web_weather
      require 'open-uri'
      url = "https://weather.gc.ca/past_conditions/index_e.html?station=yow"
      doc = Nokogiri::HTML(open(url))
      currentDate = Date.today
      doc.css("tbody tr").each do |item|
        if date = item.at_css('th')
          currentDate = date.text;
        else


          time = item.children[1].text
          temperature = item.children[5].text.split("\u{00A0}")[0]#.gsub!(/\W/,'') # it's a non-breaking space, not a regular space
          wind = item.children[9].text.split(" ") 
          wind_dir = wind[0].strip
          wind_speed = wind[1]
          humidity = item.children[13].text
          dew_point = item.children[15].text
          pressure = item.children[19].text
          historicalDateTime = DateTime.parse("#{currentDate} #{time} #{Time.zone}")
         # puts "#{historicalDateTime} - #{temperature} - #{wind_dir} - #{wind_speed} - #{pressure}"


          reading = WeatherReading.where(reading_at: historicalDateTime.utc).first_or_initialize
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

  end

end
