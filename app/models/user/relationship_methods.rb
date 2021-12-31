# frozen_string_literal: true

module User::RelationshipMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_friends, :ordered_friends
  define_cursor_paginator :cursored_followers, :ordered_followers

  def ordered_friends
    friends.reverse_order.includes(:profile)
  end

  def ordered_followers
    followers.reverse_order.includes(:profile)
  end
end
