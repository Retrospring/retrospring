# frozen_string_literal: true

class PushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: :push_notification, retry: 0

  def perform(notification_id)
  end
end
