module User::PushNotificationMethods
  def push_notification(app, resource)
    raise ArgumentError("Resource must respond to `as_push_notification`") unless resource.respond_to? :as_push_notification

    web_push_subscriptions.each do |s|
      n = Rpush::Webpush::Notification.new
      n.app = app
      n.registration_ids = [s.subscription.symbolize_keys]
      n.data = {
        message: resource.as_push_notification
      }
      n.save!
    end
  end
end
