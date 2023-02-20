# frozen_string_literal: true

module User::TimelineMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_timeline, :timeline

  # @return [ActiveRecord::Relation<Answer>] the user's timeline
  def timeline
    Answer
      .then do |query|
        blocked_and_muted_user_ids = blocked_user_ids_cached + muted_user_ids_cached
        next query if blocked_and_muted_user_ids.empty?

        # build a more complex query if we block or mute someone
        # otherwise the query ends up as "anon OR (NOT anon AND user_id NOT IN (NULL))" which will only return anonymous questions
        query
          .joins(:question)
          .where("questions.author_is_anonymous OR (NOT questions.author_is_anonymous AND questions.user_id NOT IN (?))", blocked_and_muted_user_ids)
      end
      .where("answers.user_id in (?) OR answers.user_id = ?", following_ids, id)
      .order(:created_at)
      .reverse_order
      .includes(comments: %i[user smiles], question: { user: :profile }, user: [:profile], smiles: [:user])
  end
end
