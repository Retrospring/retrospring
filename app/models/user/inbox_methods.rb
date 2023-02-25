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
    Rails.cache.fetch("#{inbox_cache_key}/unread_inbox_count") do
      count = Inbox.select("COUNT(id) AS count")
                   .where(new: true)
                   .where(user_id: id)
                   .group(:user_id)
                   .order(:count)
                   .first
      return nil if count.nil?
      return nil unless count.count.positive?

      count.count
    end
  end

  def inbox_cache_key = "#{cache_key}-#{inbox_updated_at}"
end
