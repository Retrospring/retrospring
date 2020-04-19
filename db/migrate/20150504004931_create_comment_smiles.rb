class CreateCommentSmiles < ActiveRecord::Migration[4.2]
  def change
    create_table :comment_smiles do |t|
      t.integer :user_id
      t.integer :comment_id

      t.timestamps null: false
    end

    add_index :comment_smiles, :user_id
    add_index :comment_smiles, :comment_id
    add_index :comment_smiles, [:user_id, :comment_id], unique: true

    add_column :users,    :comment_smiled_count, :integer, default: 0, null: false
    add_column :comments, :smile_count,          :integer, default: 0, null: false
  end
end
