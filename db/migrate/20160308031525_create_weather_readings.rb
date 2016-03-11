class CreateWeatherReadings < ActiveRecord::Migration
  def change
    create_table :weather_readings do |t|
      t.datetime :reading_at
      t.decimal :temperature

      t.timestamps null: false
    end
  end
end
