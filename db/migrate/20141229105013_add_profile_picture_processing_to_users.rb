class AddProfilePictureProcessingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_picture_processing, :boolean
  end
end
