class AddSupporterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :supporter, :boolean, default: false
  end
end
