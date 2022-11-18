# frozen_string_literal: true

class AddInputPlaceholderToThemes < ActiveRecord::Migration[6.1]
  def up
    add_column :themes, :input_placeholder, :integer, default: 0x6C757D, null: false
  end

  def down
    remove_column :themes, :input_placeholder
  end
end
