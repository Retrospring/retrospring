# frozen_string_literal: true

class SetOnDeleteForMuteRules < ActiveRecord::Migration[6.1]
  def change
    change_table :mute_rules do |t|
      t.foreign_key :users, on_delete: :cascade
    end
  end
end
