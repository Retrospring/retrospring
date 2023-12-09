# frozen_string_literal: true

class AddIndexOnUserBansUserId < ActiveRecord::Migration[7.0]
  def change
    add_index :user_bans, :user_id
  end
end
