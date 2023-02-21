# frozen_string_literal: true

module Question::AnswerMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_answers, :ordered_answers

  def ordered_answers(current_user: nil)
    answers
      .then do |query|
        next query unless current_user

        blocked_and_muted_user_ids = current_user.blocked_user_ids_cached + current_user.muted_user_ids_cached
        next query if blocked_and_muted_user_ids.empty?

        query
          .where.not(answers: { user_id: blocked_and_muted_user_ids })
      end
      .order(:created_at)
      .reverse_order
  end
end
