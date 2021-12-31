class RemoveRelationshipCountersFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :follower_count
    remove_column :users, :friend_count
  end
end
