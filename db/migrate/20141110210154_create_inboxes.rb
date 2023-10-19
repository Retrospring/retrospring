# frozen_string_literal: true

class CreateInboxes < ActiveRecord::Migration[4.2]
  def change
    create_table :inboxes do |t|
      t.integer :user_id
      t.integer :question_id
      t.boolean :new

      t.timestamps
    end
  end
end
