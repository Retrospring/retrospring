# frozen_string_literal: true

class Settings::PrivacyController < ApplicationController
  before_action :authenticate_user!

  def edit; end

  def update
    user_attributes = params.require(:user).permit(:privacy_lock_inbox,
                                                   :privacy_allow_anonymous_questions,
                                                   :privacy_allow_public_timeline,
                                                   :privacy_allow_stranger_answers,
                                                   :privacy_show_in_search,
                                                   :privacy_require_user)
    if current_user.update(user_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
    redirect_to settings_privacy_path
  end
end
