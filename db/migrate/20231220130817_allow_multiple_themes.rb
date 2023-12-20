# frozen_string_literal: true

class AllowMultipleThemes < ActiveRecord::Migration[7.0]
  def up
    change_table :themes, bulk: true do |t|
      t.boolean :active, default: true, null: false
      t.string :name, null: true
    end

    change_column :themes, :active, :boolean, default: false, null: false

    add_index :themes, %i[user_id active]
  end
end
