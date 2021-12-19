class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.references :user, index: true, foreign_key: true
      t.string :display_name, length: 32
      t.string :description, length: 256
      t.string :location, length: 72
      t.string :website

      t.timestamps
    end

    User.find_each do |user|
      Profile.create!(
        user_id: user.id,
        display_name: user.display_name,
        description: user.bio,
        location: user.location,
        website: user.website,
      )
    end
  end
end
