class AddIsActiveToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :is_active, :boolean, default: :true
  end
end
