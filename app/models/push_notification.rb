class PushNotification < ActiveRecord::Base


	def self.create_send(channel, notification_message)
		subscriptions = PushSubscription.where(channel_name: channel)

		subscription_ids = []
		subscriptions.each do |subscription|
			subscription_ids.push(subscription.subscription_id)
			
			notification = PushNotification.create(subscription_id: subscription.subscription_id, read: false, message: @message, channel: subscription.channel_name)
			notification.save
   		end


   		
   		if subscription_ids.length > 0

			require 'gcm'
			gcm = GCM.new(Rails.application.secrets.google_push_api_key)

			options = {}
			response = gcm.send(subscription_ids, options)

		end

	end
end
