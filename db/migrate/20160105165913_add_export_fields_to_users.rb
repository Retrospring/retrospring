class AddExportFieldsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :export_url, :string
    add_column :users, :export_processing, :boolean, default: false, null: false
    add_column :users, :export_created_at, :datetime
  end
end
