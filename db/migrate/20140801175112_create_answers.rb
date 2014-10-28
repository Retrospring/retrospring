class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :content
      t.integer :question_id
      t.integer :comments
      t.integer :likes
      t.integer :user_id

      t.timestamps
    end
    add_index :answers, [:user_id, :created_at]
  end
end
