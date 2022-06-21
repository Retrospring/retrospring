# frozen_string_literal: true

class AddAnonDisplayNameToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :anon_display_name, :string
  end
end
