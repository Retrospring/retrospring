# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :answer_id
      t.integer :user_id

      t.timestamps
    end
    add_index :comments, %i[user_id created_at]
  end
end
