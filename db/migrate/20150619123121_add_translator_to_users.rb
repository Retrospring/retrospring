class AddTranslatorToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :translator, :boolean, default: :false
  end
end
