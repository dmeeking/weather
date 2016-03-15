class AddNotificationColumns < ActiveRecord::Migration
  def change
	add_column :push_notifications, :user_token, :string
	add_column :push_notifications, :read, :boolean
	add_column :push_notifications, :message, :string
	add_column :push_notifications, :subscription_id, :string
  end
end
