# frozen_string_literal: true

class AddTypeToNotifications < ActiveRecord::Migration[6.1]
  def up
    add_column :notifications, :type, :string
    add_index :notifications, :type

    execute "UPDATE notifications SET type = 'Notification::Commented' WHERE target_type = 'Comment'"
    execute "UPDATE notifications SET type = 'Notification::QuestionAnswered' WHERE target_type = 'Answer'"
    execute "UPDATE notifications SET type = 'Notification::StartedFollowing' WHERE target_type = 'Relationship'"
    execute <<~SQUIRREL
      UPDATE notifications
      SET type = 'Notification::Smiled'
      WHERE target_type = 'Appendable'
        AND target_id IN (SELECT id FROM appendables WHERE type = 'Appendable::Reaction' AND parent_type = 'Answer');
    SQUIRREL
    execute "UPDATE notifications SET type = 'Notification::CommentSmiled' WHERE type IS NULL"

    change_column_null :notifications, :type, false
  end

  def down
    remove_index :notifications, :type
    remove_column :notifications, :type
  end
end
