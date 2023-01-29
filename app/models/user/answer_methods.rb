# frozen_string_literal: true

module User::AnswerMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_answers, :ordered_answers

  # @return [ActiveRecord::Relation<Answer>] List of a user's answers
  def ordered_answers
    answers
      .order(:created_at)
      .reverse_order
      .includes(comments: %i[user smiles], question: { user: :profile }, smiles: [:user])
  end
end
