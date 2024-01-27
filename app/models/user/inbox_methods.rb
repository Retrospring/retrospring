# frozen_string_literal: true

module User::InboxMethods
  def unread_inbox_count
    Rails.cache.fetch(inbox_cache_key, expires_in: 12.hours) do
      count = InboxEntry.where(new: true, user_id: id).count(:id)

      # Returning +nil+ here in order to not display a counter
      # at all when there isn't anything in the user's inbox
      return nil unless count.positive?

      count
    end
  end

  def inbox_cache_key = "#{cache_key}/unread_inbox_count-#{inbox_updated_at}"
end
