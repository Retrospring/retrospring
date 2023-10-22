# frozen_string_literal: true

class AddSmiledCountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :smiled_count, :integer, default: 0, null: false
  end
end
