class AddCropValuesToUsers < ActiveRecord::Migration
  def change
    # this is a ugly hack and will stay until I find a way to pass parameters
    # to the paperclip Sidekiq worker.  oh well.
    add_column :users, :crop_x, :integer
    add_column :users, :crop_y, :integer
    add_column :users, :crop_w, :integer
    add_column :users, :crop_h, :integer
  end
end
