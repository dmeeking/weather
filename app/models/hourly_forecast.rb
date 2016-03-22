class HourlyForecast < ActiveRecord::Base



# called by a rake task that is scheduled to run every hour
  def self.gather_web_forecast
      forecast_count = 0
      require 'open-uri'
      url = "https://weather.gc.ca/forecast/hourly/on-118_metric_e.html"
      doc = Nokogiri::HTML(open(url))
      currentDate = Date.today
      timeOffset = Time.zone.now.formatted_offset

      doc.css("tbody tr").each do |item|
        if date = item.at_css('th')
          currentDate = date.text;
        else


          time = item.children[1].text
          temperature = item.children[3].text #.split("\u{00A0}")[0].gsub!(/\W/,'') # it's a non-breaking space, not a regular space
          wind = item.children[9].text.split("\u{00A0}") # it's a non-breaking space, not a regular space
          wind_dir = wind[0].gsub!(/\W/,'').strip
          wind_speed = wind[1]
       
          historicalDateTime = DateTime.parse("#{currentDate} #{time} #{timeOffset}")
         # puts "#{historicalDateTime} - #{temperature} - #{wind_dir} - #{wind_speed}"

          forecast = HourlyForecast.where(reading_at: historicalDateTime.utc).first_or_initialize
          if forecast.new_record?
            forecast_count = forecast_count + 1
          end
          forecast.temperature = temperature
          forecast.wind_speed = wind_speed
          forecast.wind_direction = wind_dir
          forecast.save! #throw an exception if there are validation errors
          
        end

      end
      forecast_count
  end
end
