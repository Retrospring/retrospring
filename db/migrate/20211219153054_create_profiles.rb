# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.references :user, index: true, foreign_key: true
      t.string :display_name, length: 50
      t.string :description, length: 200, null: false, default: ""
      t.string :location, length: 72, null: false, default: ""
      t.string :website, null: false, default: ""
      t.string :motivation_header, null: false, default: ""

      t.timestamps
    end

    transaction do
      execute "INSERT INTO profiles (user_id, display_name, description, location, website, motivation_header, created_at, updated_at) SELECT users.id as user_id, users.display_name, users.bio as description, users.location, users.website, users.motivation_header, users.created_at, users.updated_at FROM users;"

      remove_column :users, :display_name
      remove_column :users, :bio
      remove_column :users, :location
      remove_column :users, :website
      remove_column :users, :motivation_header
    end
  end
end
