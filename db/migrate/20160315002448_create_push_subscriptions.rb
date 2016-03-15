class CreatePushSubscriptions < ActiveRecord::Migration
  def change
    create_table :push_subscriptions do |t|
      t.string :user_token
      t.string :channel_name
      t.string :subscription_id

      t.timestamps null: false
    end
  end
end
