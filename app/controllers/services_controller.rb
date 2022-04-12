# frozen_string_literal: true

class ServicesController < ApplicationController
  before_action :authenticate_user!

  def index
    @services = current_user.services
  end

  def create
    service = Service.initialize_from_omniauth(omniauth_hash)
    service.user = current_user

    if service.save
      flash[:success] = t(".success")
    else
      flash[:error] = if service.errors.details[:uid]&.any? { |err| err[:error] == :taken }
                        t(".duplicate", service: service.type.split("::").last.titleize, app: APP_CONFIG["site_name"])
                      else
                        t(".error")
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
    @service.destroy
    flash[:success] = t(".success")
    redirect_to services_path
  end

  private

  def origin
    request.env["omniauth.origin"]
  end

  def omniauth_hash
    request.env["omniauth.auth"]
  end
end
