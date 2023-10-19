# frozen_string_literal: true

class AddMotivationHeaderToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :motivation_header, :string, default: "", null: false
  end
end
