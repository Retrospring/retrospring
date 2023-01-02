# frozen_string_literal: true

class CreateWebPushSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :web_push_subscriptions do |t|
      t.bigint :user_id, null: false
      t.json :subscription
      t.timestamps
    end

    add_index :web_push_subscriptions, :user_id
  end
end
