# frozen_string_literal: true

class AddInboxLockedToUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :privacy_lock_inbox, :boolean, default: false
  end

  def down
    remove_column :users, :privacy_lock_inbox
  end
end
