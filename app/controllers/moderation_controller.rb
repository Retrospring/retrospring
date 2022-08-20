class ModerationController < ApplicationController
  before_action :authenticate_user!

  def toggle_unmask
    session[:moderation_view] = !session[:moderation_view]
    redirect_back fallback_location: root_path
  end
end
