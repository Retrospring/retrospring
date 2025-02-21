# frozen_string_literal: true

class Settings::ProfilePictureController < ApplicationController
  before_action :authenticate_user!
  before_action -> { not_readonly_flash!("settings/profile/edit") }, only: %i[update]

  def update
    user_attributes = params.require(:user).permit(:show_foreign_themes, :profile_picture_x, :profile_picture_y, :profile_picture_w, :profile_picture_h,
                                                   :profile_header_x, :profile_header_y, :profile_header_w, :profile_header_h, :profile_picture, :profile_header)
    if current_user.update(user_attributes)
      text = t(".success")
      text += t(".notice.profile_picture") if user_attributes[:profile_picture]
      text += t(".notice.profile_header") if user_attributes[:profile_header]
      flash[:success] = text
    else
      # CarrierWave resets the image to the default upon an error
      current_user.reload
    end

    render "settings/profile/edit"
  end
end
