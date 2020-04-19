class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|
      t.string :content
      t.boolean :author_is_anonymous
      t.string :author_name
      t.string :author_email
      t.integer :user_id

      t.timestamps
    end
    add_index :questions, [:user_id, :created_at]
  end
end
