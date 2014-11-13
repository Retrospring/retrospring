class AddSmiledCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :smiled_count, :integer, default: 0, null: false
  end
end
