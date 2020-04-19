class AddCountsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :friend_count, :integer, default: 0, null: false
    add_column :users, :follower_count, :integer, default: 0, null: false
    add_column :users, :asked_count, :integer, default: 0, null: false
    add_column :users, :answered_count, :integer, default: 0, null: false
    add_column :users, :commented_count, :integer, default: 0, null: false
  end
end
