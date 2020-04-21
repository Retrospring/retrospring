# frozen_string_literal: true

module User::QuestionMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_questions, :ordered_questions

  def ordered_questions
    questions
      .order(:created_at)
      .reverse_order
  end
end
