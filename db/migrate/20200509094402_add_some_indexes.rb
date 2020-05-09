# frozen_string_literal: true

class AddSomeIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :answers, :question_id
    add_index :comments, :answer_id
    add_index :inboxes, :user_id
    add_index :reports, %i[type target_id]
    add_index :reports, %i[user_id created_at]
    add_index :services, :user_id
    add_index :subscriptions, %i[user_id answer_id]
  end
end
