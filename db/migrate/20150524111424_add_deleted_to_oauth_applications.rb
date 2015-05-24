class AddDeletedToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :deleted, :boolean, default: false
  end
end
