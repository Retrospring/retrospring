# frozen_string_literal: true

class RemoveExpiredServiceConnectionNotifications < ActiveRecord::Migration[6.1]
  def up = Notification.where(type: "Notification::ServiceTokenExpired").delete_all

  def down = raise ActiveRecord::IrreversibleMigration
end
