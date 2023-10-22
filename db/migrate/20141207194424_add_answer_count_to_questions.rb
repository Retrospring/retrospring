# frozen_string_literal: true

class AddAnswerCountToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :answer_count, :integer, default: 0, null: false
  end
end
