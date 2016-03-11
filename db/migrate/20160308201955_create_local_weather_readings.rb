class CreateLocalWeatherReadings < ActiveRecord::Migration
  def change
    create_table :local_weather_readings do |t|
      t.datetime :recorded_at
      t.decimal :temperature

      t.timestamps null: false
    end
  end
end
