# frozen_string_literal: true

module User::QuestionMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_questions, :ordered_questions

  # @return [ActiveRecord::Relation<Question>] List of questions sent by the user
  def ordered_questions(author_is_anonymous: nil, direct: nil)
    questions
      .where({ author_is_anonymous:, direct: }.compact)
      .order(:created_at)
      .reverse_order
  end
end
