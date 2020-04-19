class AddProfilePictureProcessingToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :profile_picture_processing, :boolean
  end
end
