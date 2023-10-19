# frozen_string_literal: true

class AddBloggerToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :blogger, :boolean, default: false
  end
end
