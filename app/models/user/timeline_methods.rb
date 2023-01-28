# frozen_string_literal: true

module User::TimelineMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_timeline, :timeline

  # @return [ActiveRecord::Relation<Answer>] the user's timeline
  def timeline
    Answer
      .where("user_id in (?) OR user_id = ?", following_ids, id)
      .order(:created_at)
      .reverse_order
      .includes(comments: %i[user smiles], question: { user: :profile }, user: [:profile], smiles: [:user])
  end
end
