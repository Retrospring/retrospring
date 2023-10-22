# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
      t.integer :user_id, null: false
      t.string :name
      t.string :display_name
      t.boolean :private, default: true

      t.timestamps
    end

    add_index :groups, :user_id
    add_index :groups, :name
    add_index :groups, %i[user_id name], unique: true

    create_table :group_members do |t|
      t.integer :group_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :group_members, :group_id
    add_index :group_members, :user_id
    add_index :group_members, %i[group_id user_id], unique: true
  end
end
