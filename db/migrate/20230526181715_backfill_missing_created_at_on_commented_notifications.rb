# frozen_string_literal: true

class BackfillMissingCreatedAtOnCommentedNotifications < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQUIRREL
      UPDATE notifications
      SET created_at = comments.created_at, updated_at = comments.created_at
      FROM comments
      WHERE notifications.target_id = comments.id AND notifications.created_at IS NULL AND notifications.type = 'Notification::Commented'
    SQUIRREL

    # clean up notifications for deleted comments
    Notification::Commented.where(created_at: nil).destroy_all
  end

  def down; end
end
