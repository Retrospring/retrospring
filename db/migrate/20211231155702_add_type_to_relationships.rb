class AddTypeToRelationships < ActiveRecord::Migration[5.2]
  def up
    add_column :relationships, :type, :string

    execute %(update relationships set type = 'Relationships::Follow')

    change_column_null :relationships, :type, false
    add_index :relationships, :type
  end

  def down
    execute %(delete from relationships where type <> 'Relationships::Follow')

    remove_column :relationships, :type
  end
end
