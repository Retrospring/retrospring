# frozen_string_literal: true

class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :mark_notifications_as_read, only: %i[index]

  def index
    @services = current_user.services
  end

  def create
    service = Service.initialize_from_omniauth(omniauth_hash)
    service.user = current_user
    service_name = service.type.split("::").last.titleize

    if service.save
      flash[:success] = t(".success", service: service_name)
    else
      flash[:error] = if service.errors.details[:uid]&.any? { |err| err[:error] == :taken }
                        t(".duplicate", service: service_name, app: APP_CONFIG["site_name"])
                      else
                        t(".error", service: service_name)
                      end
    end

    redirect_to origin || services_path
  end

  def update
    service = current_user.services.find(params[:id])
    service.post_tag = params[:service][:post_tag].tr("@", "")
    if service.save
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
    redirect_to services_path
  end

  def failure
    Rails.logger.info "oauth error: #{params.inspect}"
    flash[:error] = t(".error")
    redirect_to services_path
  end

  def destroy
    @service = current_user.services.find(params[:id])
    service_name = @service.type.split("::").last.titleize
    @service.destroy
    flash[:success] = t(".success", service: service_name)
    redirect_to services_path
  end

  private

  def origin
    request.env["omniauth.origin"]
  end

  def omniauth_hash
    request.env["omniauth.auth"]
  end

  def mark_notifications_as_read
    Notification::ServiceTokenExpired
      .where(recipient: current_user, new: true)
      .update_all(new: false) # rubocop:disable Rails/SkipsModelValidations
  end
end
