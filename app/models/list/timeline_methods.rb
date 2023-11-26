# frozen_string_literal: true

module List::TimelineMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_timeline, :timeline

  # @return [ActiveRecord::Relation<Answer>] the lists' timeline
  def timeline(current_user: nil)
    Answer
      .for_user(current_user)
      .includes([{ user: :profile }, :question])
      .then do |query|
        next query unless current_user

        blocked_and_muted_user_ids = current_user.blocked_user_ids_cached + current_user.muted_user_ids_cached
        next query if blocked_and_muted_user_ids.empty?

        # build a more complex query if we block or mute someone
        # otherwise the query ends up as "anon OR (NOT anon AND user_id NOT IN (NULL))" which will only return anonymous questions
        query
          .joins(:question)
          .where("questions.author_is_anonymous OR (NOT questions.author_is_anonymous AND questions.user_id NOT IN (?))", blocked_and_muted_user_ids)
          .where.not(answers: { user_id: blocked_and_muted_user_ids })
      end
      .where(answers: { user_id: members.pluck(:user_id) }).order(:created_at).reverse_order
  end
end
