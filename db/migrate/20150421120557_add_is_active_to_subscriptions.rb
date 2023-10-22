# frozen_string_literal: true

class AddIsActiveToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :is_active, :boolean, default: true
  end
end
