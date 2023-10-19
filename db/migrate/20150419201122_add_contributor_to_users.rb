# frozen_string_literal: true

class AddContributorToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :contributor, :boolean, default: false
  end
end
