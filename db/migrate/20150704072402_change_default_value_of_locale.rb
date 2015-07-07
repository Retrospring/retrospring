class ChangeDefaultValueOfLocale < ActiveRecord::Migration
  def change
    change_column :users, :locale, :string, :default => 'en'
  end
end
