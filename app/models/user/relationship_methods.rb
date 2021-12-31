# frozen_string_literal: true

module User::RelationshipMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_followings, :ordered_followings
  define_cursor_paginator :cursored_followers, :ordered_followers

  def ordered_followings
    followings.reverse_order.includes(:profile)
  end

  def ordered_followers
    followers.reverse_order.includes(:profile)
  end
end
