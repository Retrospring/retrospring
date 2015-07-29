# Cache theme CSS if in production
__THEME_CSS_CACHE = if Rails.env == 'production'
  File.read Rails.root.join 'app/views/user/theme.css.scss.erb'
end.freeze
