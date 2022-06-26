# frozen_string_literal: true

class Settings::ThemeController < ApplicationController
  include ThemeHelper

  before_action :authenticate_user!

  def edit; end

  def update
    update_attributes = params.require(:theme).permit(%i[
                                                        primary_color primary_text
                                                        danger_color danger_text
                                                        success_color success_text
                                                        warning_color warning_text
                                                        info_color info_text
                                                        dark_color dark_text
                                                        light_color light_text
                                                        raised_background raised_accent
                                                        background_color body_text
                                                        muted_text input_color
                                                        input_text
                                                      ])

    if current_user.theme.nil?
      current_user.theme = Theme.new update_attributes
      current_user.theme.user_id = current_user.id

      if current_user.theme.save
        flash[:success] = t(".success")
      else
        flash[:error] = t(".error", errors: current_user.theme.errors.messages.flatten.join(" "))
      end
    elsif current_user.theme.update(update_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error", errors: current_user.theme.errors.messages.flatten.join(" "))
    end
    redirect_to settings_theme_path
  end

  def destroy
    current_user.theme.destroy!
    redirect_to settings_theme_path
  end
end
