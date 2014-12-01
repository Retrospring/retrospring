class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :website, :string, default: '', null: false
    add_column :users, :location, :string, default: '', null: false
    add_column :users, :bio, :text, default: '', null: false
  end
end
