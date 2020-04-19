class AddSupporterToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :supporter, :boolean, default: false
  end
end
