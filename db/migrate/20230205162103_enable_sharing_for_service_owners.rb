# frozen_string_literal: true

class EnableSharingForServiceOwners < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQUIRREL
      UPDATE users
      SET sharing_enabled = true
      WHERE id IN (SELECT user_id FROM services);
    SQUIRREL
  end

  def down; end
end
