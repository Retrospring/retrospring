class RenameCropFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :crop_h, :profile_picture_h
    rename_column :users, :crop_w, :profile_picture_w
    rename_column :users, :crop_x, :profile_picture_x
    rename_column :users, :crop_y, :profile_picture_y
    rename_column :users, :crop_h_h, :profile_header_h
    rename_column :users, :crop_h_w, :profile_header_w
    rename_column :users, :crop_h_x, :profile_header_x
    rename_column :users, :crop_h_y, :profile_header_y
  end
end
