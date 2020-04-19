class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.string :type,       null: false
      t.integer :target_id, null: false
      t.integer :user_id,   null: false

      t.timestamps
    end
  end
end
