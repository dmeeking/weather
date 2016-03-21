require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
    "#{job}".constantize.perform_later
  end

  every(4.minutes, 'LocalWeatherJob')
  every(1.hour, 'YowWeatherJob', :at => '**:20')

end