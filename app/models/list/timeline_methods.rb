# frozen_string_literal: true

module List::TimelineMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_timeline, :timeline

  # @return [Array] the lists' timeline
  def timeline
    Answer.where('user_id in (?)', members.pluck(:user_id)).order(:created_at).reverse_order
  end
end
