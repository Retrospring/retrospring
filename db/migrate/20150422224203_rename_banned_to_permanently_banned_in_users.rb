# frozen_string_literal: true

class RenameBannedToPermanentlyBannedInUsers < ActiveRecord::Migration[4.2]
  def up
    rename_column :users, :banned, :permanently_banned
  end

  def down
    rename_column :users, :permanently_banned, :banned
  end
end
