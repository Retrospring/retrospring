class AddModeratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :moderator, :boolean, default: false, null: false
  end
end
