# frozen_string_literal: true

class AddSharingFieldsToUser < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :sharing_enabled, :boolean, default: false
    add_column :users, :sharing_autoclose, :boolean, default: false
    add_column :users, :sharing_custom_url, :string
  end

  def down
    remove_column :users, :sharing_enabled
    remove_column :users, :sharing_autoclose
    remove_column :users, :sharing_custom_url
  end
end
