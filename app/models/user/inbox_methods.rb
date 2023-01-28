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
end
