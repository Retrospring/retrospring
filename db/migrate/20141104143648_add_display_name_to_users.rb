class AddDisplayNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :display_name, :string
  end
end
