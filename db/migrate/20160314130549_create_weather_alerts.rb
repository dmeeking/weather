class CreateWeatherAlerts < ActiveRecord::Migration
  def change
    create_table :weather_alerts do |t|
      t.boolean :active
      t.string :title
      t.string :link
      t.datetime :published_at
      t.string :category
      t.text :summary
      t.string :alert_id
      
      t.timestamps null: false
    end
  end
end
