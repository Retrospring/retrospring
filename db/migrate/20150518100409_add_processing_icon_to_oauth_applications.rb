class AddProcessingIconToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :icon_processing, :boolean
  end
end
