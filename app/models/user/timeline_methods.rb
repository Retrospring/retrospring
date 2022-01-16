# frozen_string_literal: true

module User::TimelineMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_timeline, :timeline

  # @return [Array] the users' timeline
  def timeline
    Answer.where("user_id in (?) OR user_id = ?", following_ids, id).order(:created_at).reverse_order.includes(comments: %i[user smiles], question: [:user], user: [:profile], smiles: [:user])
  end
end
