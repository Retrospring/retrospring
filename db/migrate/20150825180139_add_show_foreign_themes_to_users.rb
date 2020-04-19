class AddShowForeignThemesToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :show_foreign_themes, :boolean, default: true, null: false
  end
end
