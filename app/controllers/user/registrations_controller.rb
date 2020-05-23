class User::RegistrationsController < Devise::RegistrationsController
  def create
    if captcha_valid?
      super
    else
      respond_with_navigational(resource){ redirect_to new_user_registration_path }
    end
  end

  def destroy
    DeletionWorker.perform_async(resource.id)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_flashing_format?
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  private

  def captcha_valid?
    # If the captcha isn't enabled, treat it as being correct
    return true unless APP_CONFIG.dig(:hcaptcha, :enabled)

    verify_hcaptcha
  end
end
