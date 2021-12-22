class CreateMuteRules < ActiveRecord::Migration[5.2]
  def change
    create_table :mute_rules do |t|
      t.references :user, foreign_key: true
      t.string :muted_phrase

      t.timestamps
    end
  end
end
