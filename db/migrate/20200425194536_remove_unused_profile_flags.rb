# frozen_string_literal: true

class RemoveUnusedProfileFlags < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :admin
    remove_column :users, :blogger
    remove_column :users, :contributor
    remove_column :users, :moderator
    remove_column :users, :supporter
    remove_column :users, :translator
  end
end
