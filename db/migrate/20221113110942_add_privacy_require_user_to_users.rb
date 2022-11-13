# frozen_string_literal: true

class AddPrivacyRequireUserToUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :privacy_require_user, :boolean, default: false
  end

  def down
    remove_column :users, :privacy_require_user
  end
end
