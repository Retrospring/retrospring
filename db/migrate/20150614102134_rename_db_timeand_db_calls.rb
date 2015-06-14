class RenameDbTimeandDbCalls < ActiveRecord::Migration
  def change
    rename_column :application_metrics, :dbtime, :db_time
    rename_column :application_metrics, :dbcalls, :db_calls
  end
end
