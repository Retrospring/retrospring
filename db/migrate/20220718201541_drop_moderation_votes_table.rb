# frozen_string_literal: true

class DropModerationVotesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :moderation_votes
  end
end
