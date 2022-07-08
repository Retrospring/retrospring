# frozen_string_literal: true

class RemoveOrphanedNotifications < ActiveRecord::Migration[6.1]
  def up
    execute "DELETE FROM notifications WHERE target_type = 'Appendable' AND target_id NOT IN (SELECT id FROM appendables)"

    execute "DELETE FROM notifications WHERE target_type = 'Relationship' AND target_id NOT IN (SELECT id FROM relationships)"
  end
end
