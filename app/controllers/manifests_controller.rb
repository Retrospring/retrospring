# frozen_string_literal: true

class ManifestsController < ApplicationController
  include ThemeHelper

  skip_before_action :banned?
  skip_before_action :find_active_announcements

  def show
    expires_in 1.day
    return if fresh_when current_user&.theme

    render json: {
      name:             APP_CONFIG["site_name"],
      description:      t("about.index.subtitle"),
      start_url:        root_url,
      scope:            root_url,
      display:          "standalone",
      categories:       %w[social],
      lang:             I18n.locale,
      shortcuts:,
      icons:            webapp_icons,
      theme_color:,
      background_color: mobile_theme_color
    }
  end

  private

  def shortcuts = [
    webapp_shortcut(inbox_url, t("navigation.inbox"), "inbox")
  ]

  def webapp_shortcut(url, name, icon_name)
    {
      name:  name,
      url:   url,
      icons: [
        {
          src:   "/icons/shortcuts/#{icon_name}.svg",
          sizes: "96x96"
        }
      ]
    }
  end

  def webapp_icons
    %i[1024 512 384 192 144 128 96 72 48].map do |size|
      [
        { src: "/icons/icon_x#{size}.webp", sizes: "#{size}x#{size}", type: "image/webp", purpose: "any" },
        { src: "/icons/icon_x#{size}.png", sizes: "#{size}x#{size}", type: "image/png", purpose: "any" },
        { src: "/icons/maskable_icon_x#{size}.webp", sizes: "#{size}x#{size}", type: "image/webp", purpose: "maskable" },
        { src: "/icons/maskable_icon_x#{size}.png", sizes: "#{size}x#{size}", type: "image/png", purpose: "maskable" }
      ]
    end.flatten
  end
end
