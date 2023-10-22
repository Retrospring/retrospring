# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[4.2]
  def change
    create_table :answers do |t|
      t.string :content
      t.integer :question_id
      t.integer :comments
      t.integer :likes
      t.integer :user_id

      t.timestamps
    end
    add_index :answers, %i[user_id created_at]
  end
end
