# frozen_string_literal: true

class SetOnDeleteForAnonymousBlocks < ActiveRecord::Migration[6.1]
  def change
    change_table :anonymous_blocks do |t|
      t.remove_foreign_key :users
      t.remove_foreign_key :questions
    end
  end
end
