# Cache theme CSS if in production
$__THEME_CSS_CACHE_V1 = if Rails.env == 'production'
  File.read Rails.root.join 'app/views/user/theme.css.scss.erb'
else
  nil
end.freeze
