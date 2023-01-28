# frozen_string_literal: true

class AddPinnedAtToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :pinned_at, :timestamp
    add_index :answers, %i[user_id pinned_at]
  end
end
