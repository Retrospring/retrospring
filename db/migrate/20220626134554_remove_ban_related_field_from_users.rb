# frozen_string_literal: true

class RemoveBanRelatedFieldFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :permanently_banned, :boolean, default: false
    remove_column :users, :ban_reason, :string, default: nil
    remove_column :users, :banned_until, :datetime, default: nil
  end
end
