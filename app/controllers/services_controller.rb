class ServicesController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => :create
  before_action :authenticate_user!

  def index
    @services = current_user.services
  end

  def create
    service = Service.initialize_from_omniauth( omniauth_hash )
    service.user = current_user

    if service.save
      flash[:success] = t(".success")
    else
      if service.errors.details.has_key?(:uid) && service.errors.details[:uid].any? { |err| err[:error] == :taken }
        flash[:error] = t(".duplicate", service: service.type.split("::").last.titleize, app: APP_CONFIG["site_name"])
      else
        flash[:error] = t(".error")
      end
    end

    if origin
      redirect_to origin
    else
      redirect_to services_path
    end
  end

  def update
    service = current_user.services.find(params[:id])
    service.post_tag = params[:service][:post_tag].tr('@', '')
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
      request.env['omniauth.origin']
    end

    def omniauth_hash
      request.env['omniauth.auth']
    end
end
