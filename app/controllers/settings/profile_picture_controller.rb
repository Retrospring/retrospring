# frozen_string_literal: true

class Settings::ProfilePictureController < ApplicationController
  before_action :authenticate_user!

  def update
    user_attributes = params.require(:user).permit(:show_foreign_themes, :profile_picture_x, :profile_picture_y, :profile_picture_w, :profile_picture_h,
                                                   :profile_header_x, :profile_header_y, :profile_header_w, :profile_header_h, :profile_picture, :profile_header)
    if current_user.update(user_attributes)
      text = t(".success")
      text += t(".notice.profile_picture") if user_attributes[:profile_picture]
      text += t(".notice.profile_header") if user_attributes[:profile_header]
      flash[:success] = text
    else
      flash[:error] = t(".error")
    end

    redirect_to settings_profile_path
  end
end
