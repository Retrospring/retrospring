# frozen_string_literal: true

class UpdateThemeFields < ActiveRecord::Migration[5.2]
  def up
    # CSS file related fields
    remove_column :themes, :css_file_name
    remove_column :themes, :css_content_type
    remove_column :themes, :css_file_size
    remove_column :themes, :css_updated_at

    # Panel color fields -> Raised fields
    rename_column :themes, :panel_color, :raised_background
    remove_column :themes, :panel_text
    add_column :themes, :raised_accent, :integer, default: 0xF7F7F7

    # Default color -> Dark color
    rename_column :themes, :default_color, :dark_color
    rename_column :themes, :default_text, :dark_text

    # Light color fields
    add_column :themes, :light_color, :integer, default: 0xF8F9FA
    add_column :themes, :light_text, :integer, default: 0x000000

    # Rename some background_ fields
    rename_column :themes, :background_text, :body_text
    rename_column :themes, :background_muted, :muted_text

    # Remove obsolete fields
    remove_column :themes, :link_color
    remove_column :themes, :outline_color

    change_column_default :themes, :raised_background, 0xFFFFFF
    change_column_default :themes, :dark_color, 0x343A40
    change_column_default :themes, :body_text, 0x000000
    change_column_default :themes, :muted_text, 0x6C757D
    change_column_default :themes, :background_color, 0xF0EDF4
    change_column_default :themes, :danger_color, 0xDC3545
    change_column_default :themes, :warning_color, 0xFFC107
    change_column_default :themes, :warning_text, 0x292929
    change_column_default :themes, :info_color, 0x17A2B8
    change_column_default :themes, :success_color, 0x28A745
    change_column_default :themes, :input_color, 0xF0EDF4
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
