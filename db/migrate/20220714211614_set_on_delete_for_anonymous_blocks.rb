# frozen_string_literal: true

class SetOnDeleteForAnonymousBlocks < ActiveRecord::Migration[6.1]
  def change
    change_table :anonymous_blocks do |t|
      t.foreign_key :users, on_delete: :cascade
      t.foreign_key :questions, on_delete: :cascade
    end
  end
end
