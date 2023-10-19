# frozen_string_literal: true

class AddScreenNameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :screen_name, :string
    add_index :users, :screen_name, unique: true
  end
end
