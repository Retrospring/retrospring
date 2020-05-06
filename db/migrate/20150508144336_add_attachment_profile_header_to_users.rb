class AddAttachmentProfileHeaderToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.string :profile_header_file_name
      t.string :profile_header_content_type
      t.integer :profile_header_file_size
      t.datetime :profile_header_updated_at
      t.boolean :profile_header_processing
      t.integer :crop_h_x
      t.integer :crop_h_y
      t.integer :crop_h_w
      t.integer :crop_h_h
    end
  end
end
