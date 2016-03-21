require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(4.minutes, 'Get local weather') { WeatherReading.gather_local_weather}
end