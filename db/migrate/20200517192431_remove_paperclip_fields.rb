class RemovePaperclipFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :profile_picture_content_type
    remove_column :users, :profile_picture_file_size
    remove_column :users, :profile_picture_updated_at
    remove_column :users, :profile_header_content_type
    remove_column :users, :profile_header_file_size
    remove_column :users, :profile_header_updated_at
  end
end
