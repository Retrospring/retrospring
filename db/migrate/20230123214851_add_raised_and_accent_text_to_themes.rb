# frozen_string_literal: true

class AddRaisedAndAccentTextToThemes < ActiveRecord::Migration[6.1]
  def up
    add_column :themes, :raised_text, :integer, default: 0x000000, null: false
    add_column :themes, :raised_accent_text, :integer, default: 0x000000, null: false
  end

  def down
    remove_column :themes, :raised_text
    remove_column :themes, :raised_accent_text
  end
end
