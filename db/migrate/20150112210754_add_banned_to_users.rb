class AddBannedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :banned, :boolean, default: false
  end
end
