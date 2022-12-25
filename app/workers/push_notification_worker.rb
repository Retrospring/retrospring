# frozen_string_literal: true

require "rpush/daemon"

class PushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: :push_notification, retry: 0

  def perform(notification_id)
    Rpush::Daemon::AppRunner.enqueue(Rpush::Client::ActiveRecord::Notification.where(id: notification_id))
  end
end
