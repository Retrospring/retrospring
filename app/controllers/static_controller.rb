# frozen_string_literal: true

class StaticController < ApplicationController
  include ThemeHelper

  def index
    if user_signed_in?
      @timeline = current_user.cursored_timeline(last_id: params[:last_id])
      @timeline_last_id = @timeline.map(&:id).min
      @more_data_available = !current_user.cursored_timeline(last_id: @timeline_last_id, size: 1).count.zero?

      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    else
      return render 'static/front'
    end
  end

  def about
    user_count = User
                 .where.not(confirmed_at: nil)
                 .where("answered_count > 0")
                 .count

    current_ban_count = UserBan
                        .current
                        .joins(:user)
                        .where.not("users.confirmed_at": nil)
                        .where("users.answered_count > 0")
                        .count

    @users = user_count - current_ban_count
    @questions = Question.count
    @answers = Answer.count
    @comments = Comment.count
    @smiles = Appendable::Reaction.count
  end

  def linkfilter
    redirect_to root_path unless params[:url]
    
    @link = params[:url]
  end

  def faq

  end

  def privacy_policy

  end

  def terms

  end

  def webapp_manifest
    render json: {
      name:             APP_CONFIG["site_name"],
      description:      t(".front.subtitle"),
      start_url:        root_url(source: "pwa"),
      scope:            root_url,
      display:          "standalone",
      categories:       %w[social],
      lang:             I18n.locale,
      shortcuts:        [
        webapp_shortcut(inbox_url, t("views.navigation.inbox"), "inbox")
      ],
      icons:            webapp_icons,
      theme_color:      theme_color,
      background_color: mobile_theme_color,
    }
  end

  private

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
    %i[1024 512 384 192 128 96 72 48].map do |size|
      [
        { src: "/icons/maskable_icon_x#{size}.webp", size: "#{size}x#{size}", type: "image/webp" },
        { src: "/icons/maskable_icon_x#{size}.png", size: "#{size}x#{size}", type: "image/png" }
      ]
    end.flatten
  end
end
