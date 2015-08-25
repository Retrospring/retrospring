module ThemeHelper
  def render_theme_with_context(context = {})
    klass = Class.new do
      def initialize(hash = {})
        if hash.is_a? ActiveRecord::Base
          x = [:primary_color, :primary_text,
            :danger_color, :danger_text,
            :success_color, :success_text,
            :warning_color, :warning_text,
            :info_color, :info_text,
            :default_color, :default_text,
            :panel_color, :panel_text,
            :link_color, :background_color,
            :background_text, :background_muted]

          x.each do |v|
            next if hash[v].nil?
            self.instance_variable_set "@#{v}", ('#' + ('0000000' + hash[v].to_s(16))[-6, 6])
          end
        elsif hash.is_a? Hash
          hash.each do |k, v|
            next unless v.is_a? Fixnum

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
end
