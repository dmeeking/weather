class CreatePushNotifications < ActiveRecord::Migration
  def change
    create_table :push_notifications do |t|
      t.string :title
      t.string :link
      t.string :channel

      t.timestamps null: false
    end
  end
end
