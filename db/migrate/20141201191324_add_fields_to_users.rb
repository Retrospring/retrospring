# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :website, :string, default: "", null: false
    add_column :users, :location, :string, default: "", null: false
    add_column :users, :bio, :text, default: "", null: false
  end
end
