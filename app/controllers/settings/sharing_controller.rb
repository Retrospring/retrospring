# frozen_string_literal: true

class Settings::SharingController < ApplicationController
  before_action :authenticate_user!

  def edit; end

  def update
    user_attributes = params.require(:user).permit(:sharing_enabled,
                                                   :sharing_autoclose,
                                                   :sharing_custom_url)
    if current_user.update(user_attributes)
      flash.now[:success] = t(".success")
    else
      flash.now[:error] = t(".error")
    end

    render :edit
  end
end
