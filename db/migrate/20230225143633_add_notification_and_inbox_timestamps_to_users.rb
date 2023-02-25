# frozen_string_literal: true

class AddNotificationAndInboxTimestampsToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.timestamp :notifications_updated_at
      t.timestamp :inbox_updated_at
    end
  end
end
