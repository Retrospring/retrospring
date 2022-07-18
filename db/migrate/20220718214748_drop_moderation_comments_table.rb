# frozen_string_literal: true

class DropModerationCommentsTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :moderation_comments
  end
end
