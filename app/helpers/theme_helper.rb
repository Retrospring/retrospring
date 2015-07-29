module ThemeHelper
  def render_theme_with_context(context = {})
    klass = Class.new do
      def initialize(hash = {})
        if hash.is_a? ActiveRecord::Base
          hash = hash.serializable_hash
        end

        if hash.is_a? Hash
          hash.each do |k, v|
            self.instance_variable_set "@#{k}", v
          end
        end
      end

      def render
        style = if Rails.env == 'production'
          :compressed
        else
          :compact
        end.freeze

        erb = ERB.new File.read Rails.root.join 'app/views/user/theme.css.scss.erb'
        sass = Sass::Engine.new erb.result(binding), style: style, cache: false, load_paths: [], syntax: :scss
        return sass.render.to_s
      end
    end

    return klass.new(context).render
  end
end
