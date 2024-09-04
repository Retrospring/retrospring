# frozen_string_literal: true

class User::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_if_registrations_disabled!, only: %w[create new] # rubocop:disable Rails/LexicallyScopedActionFilter

  def destroy
    # TODO: destroy export async
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    resource.destroy
    set_flash_message :notice, :destroyed if is_flashing_format?
    yield resource if block_given?
    respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
  end

  private

  def captcha_valid?
    # If the captcha isn't enabled, treat it as being correct
    return true unless APP_CONFIG.dig(:hcaptcha, :enabled)

    verify_hcaptcha
  end

  def redirect_if_registrations_disabled!
    redirect_to root_path
  end
end
