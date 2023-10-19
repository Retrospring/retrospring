# frozen_string_literal: true

class CreateThemes < ActiveRecord::Migration[4.2]
  def change
    create_table :themes do |t|
      t.integer :user_id, null: false

      t.integer :primary_color, limit: 4, default: 0x5E35B1
      t.integer :primary_text, limit: 4, default: 0xFFFFFF

      t.integer :danger_color, limit: 4, default: 0xFF0039
      t.integer :danger_text, limit: 4, default: 0xFFFFFF

      t.integer :success_color, limit: 4, default: 0x3FB618
      t.integer :success_text, limit: 4, default: 0xFFFFFF

      t.integer :warning_color, limit: 4, default: 0xFF7518
      t.integer :warning_text, limit: 4, default: 0xFFFFFF

      t.integer :info_color, limit: 4, default: 0x9954BB
      t.integer :info_text, limit: 4, default: 0xFFFFFF

      t.integer :default_color, limit: 4, default: 0x222222
      t.integer :default_text, limit: 4, default: 0xEEEEEE

      t.integer :panel_color, limit: 4, default: 0xF9F9F9
      t.integer :panel_text, limit: 4, default: 0x151515

      t.integer :link_color, limit: 4, default: 0x5E35B1

      t.integer :background_color, limit: 4, default: 0xFFFFFF
      t.integer :background_text, limit: 4, default: 0x222222
      t.integer :background_muted, limit: 4, default: 0xBBBBBB

      t.string :css_file_name
      t.string :css_content_type
      t.bigint :css_file_size
      t.datetime :css_updated_at

      t.timestamps null: false
    end

    add_index :themes, %i[user_id created_at]
  end
end
