# frozen_string_literal: true

class AddIndexesToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_index :notifications, :recipient_id
    add_index :notifications, :new
  end
end
