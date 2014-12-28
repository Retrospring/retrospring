class AddDeletedToReports < ActiveRecord::Migration
  def change
    add_column :reports, :deleted, :boolean, default: false
  end
end
