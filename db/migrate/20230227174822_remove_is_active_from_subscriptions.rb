# frozen_string_literal: true

class RemoveIsActiveFromSubscriptions < ActiveRecord::Migration[6.1]
  def up
    execute "DELETE FROM subscriptions WHERE is_active = FALSE"
    remove_column :subscriptions, :is_active
  end
end
