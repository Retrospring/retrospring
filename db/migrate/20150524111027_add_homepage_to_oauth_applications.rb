class AddHomepageToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :homepage, :string, default: ""
  end
end
