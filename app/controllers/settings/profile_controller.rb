# frozen_string_literal: true

class Settings::ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action -> { not_readonly_flash!(:edit) }, only: %i[update]

  def edit; end

  def update
    profile_attributes = params.require(:profile).permit(:display_name, :motivation_header, :website, :location, :description, :anon_display_name, :allow_long_questions)

    if current_user.profile.update(profile_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    render :edit
  end
end
