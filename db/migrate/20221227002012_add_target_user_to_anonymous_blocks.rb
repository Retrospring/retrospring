# frozen_string_literal: true

class AddTargetUserToAnonymousBlocks < ActiveRecord::Migration[6.1]
  def change
    add_reference :anonymous_blocks, :target_user, null: true, foreign_key: { to_table: :users }
  end
end
