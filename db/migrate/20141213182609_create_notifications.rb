# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.string :target_type
      t.integer :target_id
      t.integer :recipient_id
      t.boolean :new

      t.timestamps
    end
  end
end
