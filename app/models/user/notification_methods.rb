# frozen_string_literal: true

module User::NotificationMethods
  def unread_notification_count
    Rails.cache.fetch("#{notification_cache_key}/unread_notification_count") do
      count = Notification.for(self).where(new: true).count
      return nil unless count.positive?

      count
    end
  end

  def notification_cache_key = "#{cache_key}-#{notifications_updated_at}"
end
