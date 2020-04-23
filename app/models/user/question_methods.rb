# frozen_string_literal: true

module User::QuestionMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_questions, :ordered_questions

  def ordered_questions(author_is_anonymous: nil)
    questions
      .where({ author_is_anonymous: author_is_anonymous }.compact)
      .order(:created_at)
      .reverse_order
  end
end
