class AddTranslatorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :translator, :boolean
  end
end
