# frozen_string_literal: true

class Settings::TwoFactorAuthentication::OtpAuthenticationController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.otp_module_disabled?
      current_user.otp_secret_key = User.otp_random_secret(25)
      current_user.save

      qr_code = RQRCode::QRCode.new(current_user.provisioning_uri("Retrospring:#{current_user.screen_name}", issuer: "Retrospring"))

      @qr_svg = qr_code.as_svg({ offset: 4, module_size: 4, color: "000;fill:var(--primary)" }).html_safe
    else
      @recovery_code_count = current_user.totp_recovery_codes.count
    end
  end

  def update
    req_params = params.require(:user).permit(:otp_validation)
    current_user.otp_module = :enabled

    if current_user.authenticate_otp(req_params[:otp_validation], drift: APP_CONFIG.fetch(:otp_drift_period, 30).to_i)
      @recovery_keys = TotpRecoveryCode.generate_for(current_user)
      current_user.save!

      render "settings/two_factor_authentication/otp_authentication/recovery_keys"
    else
      flash[:error] = t(".error")
      redirect_to settings_two_factor_authentication_otp_authentication_path
    end
  end

  def destroy
    current_user.otp_module = :disabled
    current_user.save!
    current_user.totp_recovery_codes.delete_all
    flash[:success] = t(".success")
    redirect_to settings_two_factor_authentication_otp_authentication_path, status: :see_other
  end

  def reset
    current_user.totp_recovery_codes.delete_all
    @recovery_keys = TotpRecoveryCode.generate_for(current_user)
    render "settings/two_factor_authentication/otp_authentication/recovery_keys"
  end
end
