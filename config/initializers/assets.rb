# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Enable Rails to resolve url() asset paths to digested assets
Rails.application.config.assets.resolve_assets_in_css_urls = true

# Include node assets in asset loading
# This is IMPORTANT because in either environment (especially local) external assets
# will not be found/resolved otherwise
Rails.application.config.assets.paths << Rails.root.join("node_modules/@fortawesome/fontawesome-free/webfonts")
Rails.application.config.assets.paths << Rails.root.join("node_modules/@fontsource/lexend/files")
