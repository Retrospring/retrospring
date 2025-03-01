# frozen_string_literal: true

class RenameDeletedToResolvedReports < ActiveRecord::Migration[7.1]
  def change
    rename_column :reports, :deleted, :resolved
  end
end
