class AddShowForeignThemesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_foreign_themes, :boolean, default: true, null: false
  end
end
