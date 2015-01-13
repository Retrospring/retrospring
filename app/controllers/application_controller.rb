class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :banned?

  # check if user got hit by the banhammer of doom
  def banned?
    if current_user.present? && current_user.banned?
      name = current_user.screen_name
      # obligatory '2001: A Space Odyssey' reference
      flash[:notice] = "I'm sorry, #{name}, I'm afraid I can't do that."
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
