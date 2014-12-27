class CreateModerationComments < ActiveRecord::Migration
  def change
    create_table :moderation_comments do |t|
      t.integer :report_id
      t.integer :user_id
      t.string :content

      t.timestamps
    end

    add_index :moderation_comments, [:user_id, :created_at]
  end
end
