# frozen_string_literal: true

class CreateAppendables < ActiveRecord::Migration[6.1]
  def up
    create_table :appendables do |t|
      t.string :type, null: false
      t.bigint :user_id, null: false
      t.bigint :parent_id, null: false
      t.string :parent_type, null: false
      t.text :content

      t.timestamps
    end

    change_column :appendables, :id, :bigint
    add_index :appendables, %i[parent_id parent_type]
    add_index :appendables, %i[user_id created_at]
  end

  def down
    drop_table :appendables
  end
end
