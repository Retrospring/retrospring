module ThemeHelper
  ATTRIBUTE_MAP = {
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
    'dark_color' => 'dark',
    'dark_text' => 'dark-text',
    'light_color' => 'light',
    'light_text' => 'light-text',
    'raised_background' => 'raised-bg',
    'raised_accent' => 'raised-accent',
    'background_color' => 'background',
    'body_text' => 'body-text',
    'input_color' => 'input-bg',
    'input_text' => 'input-text',
    'muted_text' => 'muted-text'
  }.freeze

  def render_theme
    theme = get_active_theme

    return unless theme

    body = ":root {\n"

    theme.attributes.each do |k, v|
      next unless ATTRIBUTE_MAP.key?(k)

      if k.include? "text"
        hex = get_hex_color_from_theme_value(v)
        body += "\t--#{ATTRIBUTE_MAP[k]}: #{get_decimal_triplet_from_hex(hex)};\n"
      else
        body += "\t--#{ATTRIBUTE_MAP[k]}: ##{get_hex_color_from_theme_value(v)};\n"
      end
    end

    body += "}"

    content_tag(:style, body, data: { "turbolinks-track": false })
  end

  def get_active_theme
    if @user&.theme
      if user_signed_in?
        if current_user&.show_foreign_themes?
          @user.theme
        else
          current_user&.theme
        end
      else
        @user.theme
      end
    elsif current_user&.theme
      current_user.theme
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
