class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :check_locale
  before_filter :banned?

  # check if user wants to read
  def check_locale
    return I18n.locale = 'en' if Rails.env.test?

    I18n.locale = 'en'

    if params[:hl].nil?
      if current_user.present?
        I18n.locale = current_user.locale
      elsif not cookies[:lang].nil?
        I18n.locale = cookies[:lang]
      else
        I18n.locale = 'en'
      end
    else
      I18n.locale = params[:hl]
      if current_user.present?
        current_user.locale = I18n.locale
        current_user.save!
      end
    end

    cookies[:lang] = I18n.locale
  end

  # check if user got hit by the banhammer of doom
  def banned?
    if current_user.present? && current_user.banned?
      name = current_user.screen_name
      # obligatory '2001: A Space Odyssey' reference
      flash[:notice] = t('flash.ban.error', name: name)
      unless current_user.ban_reason.nil?
        flash[:notice] += "\n#{t('flash.ban.reason', reason: current_user.ban_reason)}"
      end
      if not current_user.permanently_banned?
        # TODO format banned_until
        flash[:notice] += "\n#{t('flash.ban.until', time: current_user.banned_until)}"
      end
      sign_out current_user
      redirect_to new_user_session_path
    end
  end

  include ApplicationHelper

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:screen_name, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :screen_name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:screen_name, :email, :password, :password_confirmation, :current_password) }
  end
end
