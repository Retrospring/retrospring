# frozen_string_literal: true

module User::InboxMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_inbox, :ordered_inbox

  # @return [ActiveRecord::Relation<Inbox>] the user's inbox entries
  def ordered_inbox
    inboxes
      .includes(:question, user: :profile)
      .order(:created_at)
      .reverse_order
  end

  def unread_inbox_count
    Rails.cache.fetch(inbox_cache_key) do
      count = Inbox.where(new: true, user_id: id).count(:id)

      # Returning +nil+ here in order to not display a counter
      # at all when there isn't anything in the user's inbox
      return nil unless count.positive?

      count
    end
  end

  def inbox_cache_key = "#{cache_key}/unread_inbox_count-#{inbox_updated_at}"
end
