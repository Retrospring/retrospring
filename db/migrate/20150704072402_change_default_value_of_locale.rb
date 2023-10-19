# frozen_string_literal: true

class ChangeDefaultValueOfLocale < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :locale, :string, default: "en"
  end
end
