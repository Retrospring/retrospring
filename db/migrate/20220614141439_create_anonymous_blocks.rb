# frozen_string_literal: true

class CreateAnonymousBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :anonymous_blocks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :identifier, index: true
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
