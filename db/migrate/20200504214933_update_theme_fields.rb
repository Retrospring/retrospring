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
    change_column_default :themes, :info_color, 0x17A2B8
    change_column_default :themes, :success_color, 0x28A745
    change_column_default :themes, :input_color, 0xF0EDF4
  end

  def down
    add_column :themes, :css_file_name, :string
    add_column :themes, :css_content_type, :string
    add_column :themes, :css_file_size, :integer
    add_column :themes, :css_updated_at, :datetime

    rename_column :themes, :raised_background, :panel_color 
    add_column :themes, :panel_text, :integer
    remove_column :themes, :raised_accent

    rename_column :themes, :dark_color, :default_color 
    rename_column :themes, :dark_text, :default_text

    remove_column :themes, :light_color
    remove_column :themes, :light_text

    rename_column :themes, :body_text, :background_text
    rename_column :themes, :muted_text, :background_muted

    add_column :themes, :link_color, :integer
    add_column :themes, :outline_color, :integer

    change_column_default :themes, :panel_color, 0xF9F9F9
    change_column_default :themes, :default_color, 0x222222
    change_column_default :themes, :background_text, 0x222222
    change_column_default :themes, :background_muted, 0xBBBBBB
    change_column_default :themes, :background_color, 0xFFFFFF
    change_column_default :themes, :danger_color, 0xFF0039
    change_column_default :themes, :warning_color, 0xFF7518
    change_column_default :themes, :info_color, 0x9954BB
    change_column_default :themes, :success_color, 0x3FB618
    change_column_default :themes, :input_color, 0xFFFFFF
  end
end
