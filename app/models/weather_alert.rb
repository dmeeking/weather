class WeatherAlert < ActiveRecord::Base

# called by a rake task that is scheduled to run every while
  def self.gather_alerts
    alert_count = 0
		require 'open-uri'
		url = "https://weather.gc.ca/rss/warning/on-118_e.xml"
		doc = Nokogiri::HTML(open(url))

		#de-activate all active alerts
		WeatherAlert.where(active: true).update_all(active: false)

		doc.css("entry").each do |item|

				alert_summary =item.css('summary').text
				if alert_summary != 'No watches or warnings in effect.'
					alert_url = item.css('link')[0]['href']
					alert_title = item.css('title').text
					alert_published_at = DateTime.parse(item.css('published').text)
					alert_category = item.css('category')[0]['term']
					if alert_title.ends_with? ("ENDED")
						alert_category = 'success'
					elsif alert_category == 'Alerts'
						alert_category = 'info'
					else
						alert_category = 'warning'
					end


					alert_summary = item.css('summary').text
					alert_id = item.css('id').text

					alert = WeatherAlert.where(alert_id: alert_id).first_or_initialize
					if alert.new_record?
						alert_count = alert_count + 1
					end
					alert.summary = alert_summary
					alert.link = alert_url
					alert.title = alert_title
					alert.alert_id = alert_id
					alert.published_at = alert_published_at
					alert.category = alert_category
					alert.alert_id = alert_id
					alert.active = true

					alert.save! #throw an exception if there are validation errors

					PushNotification.create_send(PushNotification::WEATHER_ALERTS, alert_title, alert_summary)

				end

      end
		alert_count
  end
end