# frozen_string_literal: true

module User::AnswerMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_answers, :ordered_answers

  # @return [ActiveRecord::Relation<Answer>] List of a user's answers
  def ordered_answers(current_user_id:)
    answers
      .for_user(current_user_id)
      .order(:created_at)
      .reverse_order
      .includes(question: { user: [:profile] })
  end
end
