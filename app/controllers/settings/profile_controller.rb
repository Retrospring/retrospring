# frozen_string_literal: true

class Settings::ProfileController < ApplicationController
  before_action :authenticate_user!

  def edit; end

  def update
    profile_attributes = params.require(:profile).permit(:display_name, :motivation_header, :website, :location, :description, :anon_display_name)

    if current_user.profile.update(profile_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to settings_profile_path
  end
end
