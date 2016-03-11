class AddNewColumnsToWeatherReading < ActiveRecord::Migration
  def change
  	add_column :weather_readings, :location, :string
  	add_column :weather_readings, :wind_speed, :integer
  	add_column :weather_readings, :wind_direction, :string
  	add_column :weather_readings, :pressure, :decimal


  	add_index :weather_readings, :reading_at

   end
end
