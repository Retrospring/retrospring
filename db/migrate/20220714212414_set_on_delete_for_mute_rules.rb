# frozen_string_literal: true

class SetOnDeleteForMuteRules < ActiveRecord::Migration[6.1]
  def change
    change_table :mute_rules do |t|
      t.remove_references :user
      t.references :user, null: false, foreign_key: true, on_delete: :cascade
    end
  end
end
