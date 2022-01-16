# frozen_string_literal: true

class RemoveRelationshipCountersFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :follower_count, :integer
    remove_column :users, :friend_count, :integer
  end
end
