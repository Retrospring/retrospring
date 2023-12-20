# frozen_string_literal: true

class RemoveDuplicateReactions < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQUIRREL
      DELETE FROM reactions
      WHERE id IN (
        SELECT id FROM (
            SELECT id, row_number() over (PARTITION BY parent_type, parent_id, user_id ORDER BY id) AS row_number FROM reactions
        )s WHERE row_number >= 2
      )
    SQUIRREL

    add_index :reactions, %i[parent_type parent_id user_id], unique: true
  end

  def down
    remove_index :reactions, %i[parent_type parent_id user_id]
  end
end
