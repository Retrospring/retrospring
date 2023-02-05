# frozen_string_literal: true

class DropServicesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :services
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
