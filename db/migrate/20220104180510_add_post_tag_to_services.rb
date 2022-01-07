class AddPostTagToServices < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :post_tag, :string, limit: 20
  end
end
