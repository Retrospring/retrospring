# frozen_string_literal: true

class Settings::ProfileController < ApplicationController
  before_action :authenticate_user!

  def edit; end

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
    redirect_to edit_user_profile_path
  end

  def update_profile
    profile_attributes = params.require(:profile).permit(:display_name, :motivation_header, :website, :location, :description, :anon_display_name)

    if current_user.profile.update(profile_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
    redirect_to edit_user_profile_path
  end
end
