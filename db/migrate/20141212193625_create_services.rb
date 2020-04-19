class CreateServices < ActiveRecord::Migration[4.2]
  def change
    create_table :services do |t|
      t.string :type,     null: false
      t.integer :user_id, null: false
      t.string :uid
      t.string :access_token
      t.string :access_secret
      t.string :nickname

      t.timestamps
    end
  end
end
