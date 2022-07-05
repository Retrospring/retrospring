# frozen_string_literal: true

class DropSmilesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :smiles
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
