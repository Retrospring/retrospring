module ThemeHelper
  def render_theme
    theme_attribute_map = {
      'primary_color' => 'primary',
      'primary_text' => 'primary-text',
      'danger_color' => 'danger',
      'danger_text' => 'danger-text',
      'warning_color' => 'warning',
      'warning_text' => 'warning-text',
      'info_color' => 'info',
      'info_text' => 'info-text',
      'success_color' => 'success',
      'success_text' => 'success-text',
      'panel_color' => 'raised-bg',
      'background_color' => 'background',
      'background_text' => 'body-text',
      'input_color' => 'input-bg',
      'input_text' => 'input-text' 
    }

    theme = get_active_theme

    if theme

    body = ":root {\n"
      theme.attributes.each do |k, v|
        if theme_attribute_map[k]
          if k.include? "text"
            hex = get_hex_color_from_theme_value(v)
            body += "\t--#{theme_attribute_map[k]}: #{get_decimal_triplet_from_hex(hex)};\n"
          else
            body += "\t--#{theme_attribute_map[k]}: ##{get_hex_color_from_theme_value(v)};\n"
          end
        end
      end

      body += "}"

      content_tag(:style, body)
    end
  end

  def get_active_theme
    if current_user&.theme
      current_user.theme
    elsif @user&.theme
      if user_signed_in?
        @user.theme unless !current_user&.show_foreign_themes?
      else
        @user.theme
      end
    end
  end

  def get_hex_color_from_theme_value(value)
    ('0000000' + value.to_s(16))[-6, 6]
  end

  def get_decimal_triplet_from_hex(value)
    hexes = value.split(/(.{2})/).reject { |c| c.empty? }
    hexes.map(&:hex).join(", ")
  end
end
