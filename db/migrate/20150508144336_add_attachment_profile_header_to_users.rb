class AddAttachmentProfileHeaderToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.attachment :profile_header
      t.boolean :profile_header_processing
      t.integer :crop_h_x
      t.integer :crop_h_y
      t.integer :crop_h_w
      t.integer :crop_h_h
    end
  end
end
