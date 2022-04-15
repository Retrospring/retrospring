# frozen_string_literal: true

class AddIndexForQuestionIdIndexOnInboxes < ActiveRecord::Migration[6.1]
  def change
    add_index :inboxes, :question_id
  end
end
