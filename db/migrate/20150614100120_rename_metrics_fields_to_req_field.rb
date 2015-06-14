class RenameMetricsFieldsToReqField < ActiveRecord::Migration
  def change
    rename_column :application_metrics, :path, :req_path
    rename_column :application_metrics, :params, :req_params
    rename_column :application_metrics, :method, :req_method
    rename_column :application_metrics, :status, :res_status
    rename_column :application_metrics, :spent, :res_timespent
  end
end
