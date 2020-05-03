module ThemeHelper
  def render_theme_with_context(context = {})
    klass = Class.new do
      def initialize(hash = {})
        if hash.is_a? ApplicationRecord
          x = [
            :primary_color, :primary_text,
            :danger_color, :danger_text,
            :success_color, :success_text,
            :warning_color, :warning_text,
            :info_color, :info_text,
            :default_color, :default_text,
            :panel_color, :panel_text,
            :link_color, :background_color,
            :background_text, :background_muted,
            :input_color, :input_text,
            :outline_color
          ]

          x.each do |v|
            next if hash[v].nil?
            self.instance_variable_set "@#{v}", ('#' + ('0000000' + hash[v].to_s(16))[-6, 6])
          end
        elsif hash.is_a? Hash
          hash.each do |k, v|
            next unless v.is_a? Integer

            self.instance_variable_set "@#{k}", ('#' + ('0000000' + hash[k].to_s(16))[-6, 6])
          end
        end
      end

      def render
        style = if Rails.env == 'production'
          :compressed
        else
          :compact
        end.freeze

        css = if $__THEME_CSS_CACHE_V1.nil?
          File.read Rails.root.join 'app/views/user/theme.css.scss.erb'
        else
          $__THEME_CSS_CACHE_V1
        end

        erb = ERB.new css
        sass = Sass::Engine.new erb.result(binding), style: style, cache: false, load_paths: [], syntax: :scss
        return sass.render.to_s
      end
    end

    return klass.new(context).render
  end

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
      'panel_color' => 'card-bg',
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
