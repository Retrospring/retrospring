# frozen_string_literal: true

class Settings::SharingController < ApplicationController
  before_action :authenticate_user!

  def edit; end

  def update
    user_attributes = params.require(:user).permit(:sharing_enabled,
                                                   :sharing_autoclose,
                                                   :sharing_custom_url)
    if current_user.update(user_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
    redirect_to settings_sharing_path
  end
end
