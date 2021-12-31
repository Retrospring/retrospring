# frozen_string_literal: true

module User::AnswerMethods
  include CursorPaginatable

  define_cursor_paginator :cursored_answers, :ordered_answers

  def ordered_answers
    answers
      .order(:created_at)
      .reverse_order
      .includes(comments: [:user, :smiles], question: [:user], smiles: [:user])
  end
end
