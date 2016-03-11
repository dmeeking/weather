module WeatherReadingValidations
  extend ActiveSupport::Concern

  included do
    validates :reading_at, :presence => true
	validates :location, :presence => true
  end
end