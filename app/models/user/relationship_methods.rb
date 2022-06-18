# frozen_string_literal: true

module User::RelationshipMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_following_relationships, :ordered_following_relationships
  define_cursor_paginator :cursored_follower_relationships, :ordered_follower_relationships

  def ordered_following_relationships
    active_follow_relationships.reverse_order.includes(target: [:profile])
  end

  def ordered_follower_relationships
    passive_follow_relationships.reverse_order.includes(source: [:profile])
  end
end
