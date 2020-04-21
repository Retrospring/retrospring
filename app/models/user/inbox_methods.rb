# frozen_string_literal: true

module User::InboxMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_inbox, :ordered_inbox

  def ordered_inbox
    inboxes
      .includes(:question, :user)
      .order(:created_at)
      .reverse_order
  end
end
