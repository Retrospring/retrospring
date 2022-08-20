# frozen_string_literal: true

class MakeUserIdOnAnonymousBlocksNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :anonymous_blocks, :user_id, true
  end
end
