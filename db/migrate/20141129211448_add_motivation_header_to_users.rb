class AddMotivationHeaderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :motivation_header, :string, default: '', null: false
  end
end
