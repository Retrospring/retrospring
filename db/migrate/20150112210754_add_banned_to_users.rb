# frozen_string_literal: true

class AddBannedToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :banned, :boolean, default: false
  end
end
