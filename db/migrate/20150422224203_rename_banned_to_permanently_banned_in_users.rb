class RenameBannedToPermanentlyBannedInUsers < ActiveRecord::Migration
  def up
    rename_column :users, :banned, :permanently_banned
  end

  def down
    rename_column :users, :permanently_banned, :banned
  end
end
