class CreateSmiles < ActiveRecord::Migration
  def change
    create_table :smiles do |t|
      t.integer :user_id
      t.integer :answer_id

      t.timestamps
    end

    add_index :smiles, :user_id
    add_index :smiles, :answer_id
    add_index :smiles, [:user_id, :answer_id], unique: true
  end
end
