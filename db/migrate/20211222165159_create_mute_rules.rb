class CreateMuteRules < ActiveRecord::Migration[5.2]
  def change
    create_table :mute_rules do |t|
      t.references :user, foreign_key: true
      t.string :muted_phrase

      t.timestamps
    end

    change_column(:mute_rules, :id, :bigint, default: -> { "gen_timestamp_id('mute_rules'::text)" })
  end
end
