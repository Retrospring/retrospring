# frozen_string_literal: true

class AddDeletedToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :deleted, :boolean, default: false
  end
end
