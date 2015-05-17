class AddOwnerAndDescriptionToApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :owner_id, :integer, null: true
    add_column :oauth_applications, :owner_type, :string, null: true
    add_column :oauth_applications, :description, :string
    add_index :oauth_applications, [:owner_id, :owner_type]
    add_index :oauth_applications, :name, unique: true
  end
end
