class AddMoreColumnsToWeatherReading < ActiveRecord::Migration
  def change
  	add_column :weather_readings, :relative_humidity, :decimal
  	add_column :weather_readings, :dew_point, :integer
  
  end
end
