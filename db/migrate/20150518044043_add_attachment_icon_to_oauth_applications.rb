class AddAttachmentIconToOauthApplications < ActiveRecord::Migration
  def self.up
    change_table :oauth_applications do |t|
      t.attachment :icon
      t.integer :crop_x
      t.integer :crop_y
      t.integer :crop_w
      t.integer :crop_h
    end
  end

  def self.down
    remove_attachment :oauth_applications, :icon
    remove_column :oauth_applications, :crop_x
    remove_column :oauth_applications, :crop_y
    remove_column :oauth_applications, :crop_w
    remove_column :oauth_applications, :crop_h
  end
end
