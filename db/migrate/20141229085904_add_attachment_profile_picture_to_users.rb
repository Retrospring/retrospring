class AddAttachmentProfilePictureToUsers < ActiveRecord::Migration[4.2]
  def self.up
    change_table :users do |t|
      t.string :profile_picture_file_name
      t.string :profile_picture_content_type
      t.integer :profile_picture_file_size
      t.datetime :profile_picture_updated_at
    end
  end

  def self.down
    remove_column :users, :profile_picture_file_name
    remove_column :users, :profile_picture_content_type
    remove_column :users, :profile_picture_file_size
    remove_column :users, :profile_picture_updated_at
  end
end
