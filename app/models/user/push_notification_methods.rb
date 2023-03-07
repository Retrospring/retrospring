# frozen_string_literal: true

module User::PushNotificationMethods
  def push_notification(app, resource)
    raise ArgumentError("Resource must respond to `as_push_notification`") unless resource.respond_to? :as_push_notification

    web_push_subscriptions.active.find_each do |s|
      n = Rpush::Webpush::Notification.new
      n.app = app
      n.registration_ids = [s.subscription.symbolize_keys]
      n.data = {
        message: resource.as_push_notification.merge(notification_data).to_json,
      }
      n.save!

      PushNotificationWorker.perform_async(n.id)
    end
  end

  def notification_data = {
    data: {
      badge: unread_inbox_count,
    },
  }
end
