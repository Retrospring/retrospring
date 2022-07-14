# frozen_string_literal: true

class SetOnDeleteForAnonymousBlocks < ActiveRecord::Migration[6.1]
  def change
    change_table :anonymous_blocks do |t|
      t.remove_references :user
      t.references :user, null: false, foreign_key: true, on_delete: :cascade

      t.remove_references :question
      t.references :question, null: true, foreign_key: true, on_delete: :null
    end
  end
end
