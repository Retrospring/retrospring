class AddSuperappBooleanToOAuthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :superapp, :boolean, default: :false, null: false
  end
end
