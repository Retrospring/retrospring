# frozen_string_literal: true

module User::TimelineMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_timeline, :timeline

  # @return [Array] the users' timeline
  def timeline
    Answer.where('user_id in (?) OR user_id = ?', friend_ids, id).order(:created_at).reverse_order
  end
end
