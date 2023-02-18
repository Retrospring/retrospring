# frozen_string_literal: true

class AddIndexForCreatedAtOnAnswers < ActiveRecord::Migration[6.1]
  def change
    add_index :answers, :created_at, order: :desc
  end
end
