class AddBloggerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :blogger, :boolean, default: :false
  end
end
