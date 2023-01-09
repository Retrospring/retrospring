# frozen_string_literal: true

class Settings::ProfilePictureController < ApplicationController
  before_action :authenticate_user!

  def update
    user_attributes = params.require(:user).permit(:show_foreign_themes, :profile_picture_x, :profile_picture_y, :profile_picture_w, :profile_picture_h,
                                                   :profile_header_x, :profile_header_y, :profile_header_w, :profile_header_h, :profile_picture, :profile_header)
    if current_user.update(user_attributes)
      flash[:success] = success_flash_message(user_attributes)
    else
      flash[:error] = t(".error")
    end

    redirect_to settings_profile_path
  end

  private

  def success_flash_message(user_attributes)
    if user_attributes[:profile_picture] && user_attributes[:profile_header]
      t(".update.success.both")
    elsif user_attributes[:profile_picture]
      t(".update.success.profile_picture")
    elsif user_attributes[:profile_header]
      t(".update.success.profile_header")
    else
      state = user_attributes[:show_foreign_themes] == "true" ? "enabled" : "disabled"
      t(".update.success.foreign_themes.#{state}")
    end
  end
end
