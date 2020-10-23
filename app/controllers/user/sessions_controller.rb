class User::SessionsController < Devise::SessionsController
  def new
    session.delete(:user_sign_in_uid)
    super
  end

  def create
    if session.has_key?(:user_sign_in_uid)
      self.resource = User.find(session.delete(:user_sign_in_uid))
    else
      self.resource = warden.authenticate!(auth_options)
    end

    if resource.active_for_authentication? && resource.otp_module_enabled?
      if params[:user][:otp_attempt].blank?
        session[:user_sign_in_uid] = resource.id
        sign_out(resource)
        warden.lock!
        render 'auth/two_factor_authentication'
      else
        if resource.authenticate_otp(params[:user][:otp_attempt])
          continue_sign_in(resource, resource_name)
        else
          sign_out(resource)
          flash[:error] = "Invalid code provided"
          redirect_to new_user_session_url
        end
      end
    else
      continue_sign_in(resource, resource_name)
    end
  end

  def two_factor_entry
    unless session.has_key? :user_sign_in_uid
      redirect_to root_url
      return
    end

    self.resource = User.find(session[:user_sign_in_uid])
    render 'auth/two_factor_authentication'
  end

  private

  def continue_sign_in(resource, resource_name)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end