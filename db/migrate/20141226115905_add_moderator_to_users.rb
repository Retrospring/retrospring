# frozen_string_literal: true

class AddModeratorToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :moderator, :boolean, default: false, null: false
  end
end
