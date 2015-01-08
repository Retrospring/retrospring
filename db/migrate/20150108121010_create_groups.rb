class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :user_id, null: false
      t.integer :target_id, null: false
      t.string :name
      t.string :display_name

      t.timestamps
    end

    add_index :groups, :user_id
    add_index :groups, :target_id
    add_index :groups, :name
    add_index :groups, [:user_id, :name], unique: true
  end
end
