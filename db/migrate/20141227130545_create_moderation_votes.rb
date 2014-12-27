class CreateModerationVotes < ActiveRecord::Migration
  def change
    create_table :moderation_votes do |t|
      t.integer :report_id, null: false
      t.integer :user_id,   null: false
      t.boolean :upvote,    null: false, default: false

      t.timestamps
    end

    add_index :moderation_votes, :user_id
    add_index :moderation_votes, :report_id
    add_index :moderation_votes, [:user_id, :report_id], unique: true
  end
end
