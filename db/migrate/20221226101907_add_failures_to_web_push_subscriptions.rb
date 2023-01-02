# frozen_string_literal: true

class AddFailuresToWebPushSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :web_push_subscriptions, :failures, :integer, default: 0
  end
end
