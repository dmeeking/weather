class CreateHourlyForecasts < ActiveRecord::Migration
  def change
    create_table :hourly_forecasts do |t|
      t.datetime :reading_at
      t.decimal :temperature
      t.integer :wind_speed
      t.string :wind_direction

      t.timestamps null: false
    end
  end
end
