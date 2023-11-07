# frozen_string_literal: true

class OptimiseIndices < ActiveRecord::Migration[7.0]
  def change
    add_index :users, "LOWER(screen_name)", order: :desc, unique: true
    remove_index :users, :screen_name, unique: true
    add_index :user_bans, :expires_at, order: :desc
    add_index :announcements, %i[starts_at ends_at], order: :desc
  end
end
