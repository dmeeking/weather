class HomeController < ApplicationController
  protect_from_forgery except: :subscribe
  def index
    @alerts = WeatherAlert.where(active: true)
  end

  def temperature_readings

  	# chartRange = 0.days.ago.midnight..-24.hours.ago
    chartRange = 12.hours.ago...-24.hours.ago
    dateFormat = '%a, %d %b %Y %H:%M:%S %z';

    allReadings = WeatherReading.where(location: 'YOW', reading_at: chartRange).order(reading_at: :asc).select(:reading_at, :temperature, :pressure, :wind_speed, :wind_direction).to_a
    allReadings = allReadings.group_by_hour(format:dateFormat, default_value:nil) {|r| r.reading_at}


    localReadings = WeatherReading.where(location: 'WBO', reading_at: chartRange).order(reading_at: :asc).select(:reading_at, :temperature, :pressure, :wind_speed, :wind_direction).to_a
    localReadings = localReadings.group_by_minute(format:dateFormat, default_value:nil) {|r| r.reading_at}
    # rip out empties
    localReadings = localReadings.delete_if { |k, v| v.length == 0 }

    forecastRange = WeatherReading.where(location: 'YOW').order(reading_at: :desc).limit(1).first.reading_at..-24.hours.ago
    allForecasts = HourlyForecast.where(reading_at: forecastRange).order(reading_at: :asc).select(:reading_at, :temperature, :wind_speed).to_a
    allForecasts = allForecasts.group_by_hour(format:dateFormat, default_value:nil) {|r| r.reading_at}

    render json: {
        observed: allReadings,
        local: localReadings,
        forecast: allForecasts,
        windDirections: wind_direction_map
      }
  end

  # returns a numerical mapping of text directions to degrees. This object gets used client-side to translate back & forth too
  def wind_direction_map
    wind_directions = ["NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"];
    magic_map = {}
    wind_directions.each_with_index { |x, index| 
        magic_map[x] = (index+1) * 22.5
     }
    magic_map
  end

  def alertinfo
      user_token =  params['token']
      alerts = PushNotification.where(user_token: user_token, read: false)
      render json: {
        alerts: alerts
      }
      alerts.update_all(read: true)
  end

  def subscribe
    user_token =  params[:token]
    channel = params[:channel]
    subscription_id = params[:sid]
    
    remove_subscriptions(user_token, channel)

    subscription = PushSubscription.create(user_token: user_token, channel_name: channel, subscription_id: subscription_id)
   

    render json: {success:true}

  end


  def list_subscriptions
    user_token =  params[:token]

    subscriptions = PushSubscription.where(user_token: user_token)

    render json: {subscriptions:subscriptions}

  end

  def remove_subscriptions(user_token, channel)


    subscriptions = PushSubscription.where(user_token: user_token)

    if channel != 'all'
      subscriptions = subscriptions.where(channel_name: channel)
    end

    subscriptions.destroy_all
 
  end

  def unsubscribe

    user_token =  params[:token]
    channel = params[:channel]

    remove_subscriptions(user_token, channel)

    render json: {success:true}

  end
end
