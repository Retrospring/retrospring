# frozen_string_literal: true

class DropCommentSmilesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :comment_smiles
  end
end
