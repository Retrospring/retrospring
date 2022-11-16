# frozen_string_literal: true

class AddPrivacyNoindexToUser < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :privacy_noindex, :boolean, default: false
  end

  def down
    remove_column :users, :privacy_noindex
  end
end
