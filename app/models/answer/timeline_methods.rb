# frozen_string_literal: true

module Answer::TimelineMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_public_timeline, :public_timeline

  def public_timeline
    joins(:user)
      .where(users: { privacy_allow_public_timeline: true })
      .order(:created_at)
      .reverse_order
  end
end
