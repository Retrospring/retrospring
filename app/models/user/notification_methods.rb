# frozen_string_literal: true

module User::NotificationMethods
  def unread_notification_count
    Rails.cache.fetch(notification_cache_key) do
      count = Notification.for(self).where(new: true).count(:id)

      # Returning +nil+ here in order to not display a counter
      # at all when there aren't any notifications
      return nil unless count.positive?

      count
    end
  end

  def notification_cache_key = "#{cache_key}/unread_notification_count-#{notifications_updated_at}"
  def notification_dropdown_cache_key = "#{cache_key}/notification_dropdown-#{notifications_updated_at}"
end
