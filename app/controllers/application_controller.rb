class ApplicationController < ActionController::Base
  include Pundit::Authorization
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :sentry_user_context
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale
  before_action :banned?
  before_action :find_active_announcements
  before_action :set_has_new_reports

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

  # check if user got hit by the banhammer of doom
  def banned?
    if current_user.present? && current_user.banned?
      name = current_user.screen_name
      # obligatory '2001: A Space Odyssey' reference
      flash[:notice] = t("user.sessions.create.banned", name:)
      current_ban = current_user.bans.current.first
      flash[:notice] += "\n#{t('user.sessions.create.reason', reason: current_ban.reason)}" unless current_ban&.reason&.empty?

      flash[:notice] += if current_ban&.permanent?
                          "\n#{t('user.sessions.create.permanent')}"
                        else
                          # TODO: format banned_until
                          "\n#{t('user.sessions.create.until', time: current_ban.expires_at)}"
                        end

      sign_out current_user
      redirect_to new_user_session_path
    end
  end

  def find_active_announcements
    @active_announcements ||= Announcement.find_active
  end

  def set_has_new_reports
    return unless current_user&.mod?

    @has_new_reports = if current_user.last_reports_visit.nil?
                         true
                       else
                         Report.where(deleted: false)
                               .where("created_at > ?", current_user.last_reports_visit)
                               .count.positive?
                       end
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
