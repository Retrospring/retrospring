class CreateInboxes < ActiveRecord::Migration
  def change
    create_table :inboxes do |t|
      t.integer :user_id
      t.integer :question_id
      t.boolean :new

      t.timestamps
    end
  end
end
