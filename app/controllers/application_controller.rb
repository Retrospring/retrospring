class ApplicationController < ActionController::Base
  include Pundit::Authorization
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :sentry_user_context
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale

  # check if user wants to read
  def switch_locale(&)
    locale = params[:lang] || current_user&.locale || cookies[:lang] || "en"
    if params[:lang] && current_user.present?
      current_user.locale = locale
      current_user.save
    end

    cookies[:lang] = locale

    I18n.with_locale(locale, &)
  end

  include ApplicationHelper

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:screen_name, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:login, :screen_name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:screen_name, :email, :password, :password_confirmation, :current_password) }
  end

  def sentry_user_context
    if current_user.present?
      Sentry.set_user({ id: current_user.id })
    else
      Sentry.set_user({ ip_address: request.remote_ip })
    end
  end
end
