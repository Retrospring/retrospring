class AddDisplayNameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :display_name, :string
  end
end
