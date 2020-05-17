class RenameCropFields < ActiveRecord::Migration[5.2]
  def up
    rename_column :users, :crop_h, :profile_picture_h
    rename_column :users, :crop_w, :profile_picture_w
    rename_column :users, :crop_x, :profile_picture_x
    rename_column :users, :crop_y, :profile_picture_y
    rename_column :users, :crop_h_h, :profile_header_h
    rename_column :users, :crop_h_w, :profile_header_w
    rename_column :users, :crop_h_x, :profile_header_x
    rename_column :users, :crop_h_y, :profile_header_y
  end

  def down
    rename_column :users, :profile_picture_h, :crop_h
    rename_column :users, :profile_picture_w, :crop_w
    rename_column :users, :profile_picture_x, :crop_x
    rename_column :users, :profile_picture_y, :crop_y
    rename_column :users, :profile_header_h, :crop_h_h
    rename_column :users, :profile_header_w, :crop_h_w
    rename_column :users, :profile_header_x, :crop_h_x
    rename_column :users, :profile_header_y, :crop_h_y
  end
end
