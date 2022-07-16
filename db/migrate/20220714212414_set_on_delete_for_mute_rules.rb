# frozen_string_literal: true

class SetOnDeleteForMuteRules < ActiveRecord::Migration[6.1]
  def change
    change_table :mute_rules do |t|
      t.remove_foreign_key :users
    end
  end
end
