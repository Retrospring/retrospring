# frozen_string_literal: true

class AddNotificationSettingsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email_notify_on_new_inbox, :integer, default: 0, null: false
  end
end
