# frozen_string_literal: true

class RenameAppendableToReaction < ActiveRecord::Migration[7.0]
  def change
    rename_table :appendables, :reactions
    remove_column :reactions, :type, :string
  end
end
