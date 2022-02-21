class UserController < ApplicationController
  include ThemeHelper

  before_action :authenticate_user!, only: %w(edit update edit_privacy update_privacy edit_theme update_theme preview_theme delete_theme data export begin_export edit_security update_2fa destroy_2fa reset_user_recovery_codes edit_mute)

  def show
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @answers = @user.cursored_answers(last_id: params[:last_id])
    @answers_last_id = @answers.map(&:id).min
    @more_data_available = !@user.cursored_answers(last_id: @answers_last_id, size: 1).count.zero?

    if user_signed_in?
      notif = Notification.where(target_type: "Relationship", target_id: @user.active_follow_relationships.where(target_id: current_user.id).pluck(:id), recipient_id: current_user.id, new: true).first
      unless notif.nil?
        notif.new = false
        notif.save
      end
    end

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  # region Account settings
  def edit
  end

  def update
    user_attributes = params.require(:user).permit(:show_foreign_themes, :profile_picture_x, :profile_picture_y, :profile_picture_w, :profile_picture_h,
                                                   :profile_header_x, :profile_header_y, :profile_header_w, :profile_header_h, :profile_picture, :profile_header)
    if current_user.update(user_attributes)
      text = t(".success")
      text += t(".notice.profile_picture") if user_attributes[:profile_picture]
      text += t(".notice.profile_header") if user_attributes[:profile_header]
      flash[:success] = text
    else
      flash[:error] = t(".error")
    end
    redirect_to edit_user_profile_path
  end

  def update_profile
    profile_attributes = params.require(:profile).permit(:display_name, :motivation_header, :website, :location, :description)

    if current_user.profile.update(profile_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
    redirect_to edit_user_profile_path
  end
  # endregion

  # region Privacy settings
  def edit_privacy
  end

  def update_privacy
    user_attributes = params.require(:user).permit(:privacy_allow_anonymous_questions,
                                                   :privacy_allow_public_timeline,
                                                   :privacy_allow_stranger_answers,
                                                   :privacy_show_in_search)
    if current_user.update(user_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
    redirect_to edit_user_privacy_path
  end
  # endregion

  # region Lists
  def lists
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @lists = if current_user == @user
                @user.lists
              else
                @user.lists.where(private: false)
              end.all
  end
  # endregion

  def followers
    @title = 'Followers'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @users = @user.cursored_followers(last_id: params[:last_id])
    @users_last_id = @users.map(&:id).min
    @more_data_available = !@user.cursored_followers(last_id: @users_last_id, size: 1).count.zero?
    @type = :friend

    respond_to do |format|
      format.html { render "show_follow" }
      format.js { render "show_follow", layout: false }
    end
  end

  # rubocop:disable Metrics/AbcSize
  def followings
    @title = 'Following'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @users = @user.cursored_followings(last_id: params[:last_id])
    @users_last_id = @users.map(&:id).min
    @more_data_available = !@user.cursored_followings(last_id: @users_last_id, size: 1).count.zero?
    @type = :friend

    respond_to do |format|
      format.html { render "show_follow" }
      format.js { render "show_follow", layout: false }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def questions
    @title = 'Questions'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @questions = @user.cursored_questions(author_is_anonymous: false, last_id: params[:last_id])
    @questions_last_id = @questions.map(&:id).min
    @more_data_available = !@user.cursored_questions(author_is_anonymous: false, last_id: @questions_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def data
  end

  def edit_theme
  end

  def delete_theme
    current_user.theme.destroy!
    redirect_to edit_user_theme_path
  end

  def update_theme
    update_attributes = params.require(:theme).permit([
      :primary_color, :primary_text,
      :danger_color, :danger_text,
      :success_color, :success_text,
      :warning_color, :warning_text,
      :info_color, :info_text,
      :dark_color, :dark_text,
      :light_color, :light_text,
      :raised_background, :raised_accent,
      :background_color, :body_text, 
      :muted_text, :input_color, 
      :input_text
    ])

    if current_user.theme.nil?
      current_user.theme = Theme.new update_attributes
      current_user.theme.user_id = current_user.id

      if current_user.theme.save
        flash[:success] = t(".success")
      else
        flash[:error] = t(".error", errors: current_user.theme.errors.messages.flatten.join(" "))
      end
    elsif current_user.theme.update(update_attributes)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error", errors: current_user.theme.errors.messages.flatten.join(" "))
    end
    redirect_to edit_user_theme_path
  end

  def export
    if current_user.export_processing
      flash[:info] = t(".info")
    end
  end

  def begin_export
    if current_user.can_export?
      ExportWorker.perform_async(current_user.id)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to user_export_path
  end

  def edit_security
    if current_user.otp_module_disabled?
      current_user.otp_secret_key = User.otp_random_secret(25)
      current_user.save

      qr_code = RQRCode::QRCode.new(current_user.provisioning_uri("Retrospring:#{current_user.screen_name}", issuer: "Retrospring"))

      @qr_svg = qr_code.as_svg({ offset: 4, module_size: 4, color: "000;fill:var(--primary)" }).html_safe
    else
      @recovery_code_count = current_user.totp_recovery_codes.count
    end
  end

  def update_2fa
    req_params = params.require(:user).permit(:otp_validation)
    current_user.otp_module = :enabled

    if current_user.authenticate_otp(req_params[:otp_validation], drift: APP_CONFIG.fetch(:otp_drift_period, 30).to_i)
      @recovery_keys = TotpRecoveryCode.generate_for(current_user)
      current_user.save!

      render "settings/security/recovery_keys"
    else
      flash[:error] = t(".error")
      redirect_to edit_user_security_path
    end
  end

  def destroy_2fa
    current_user.otp_module = :disabled
    current_user.save!
    current_user.totp_recovery_codes.delete_all
    flash[:success] = t(".success")
    redirect_to edit_user_security_path
  end

  def reset_user_recovery_codes
    current_user.totp_recovery_codes.delete_all
    @recovery_keys = TotpRecoveryCode.generate_for(current_user)
    render 'settings/security/recovery_keys'
  end

  # region Muting
  def edit_mute
    @rules = MuteRule.where(user: current_user)
  end
  # endregion

  # Notifications {{{
  def edit_notifications
  end

  def update_notifications
    update_params = params.require(:user).permit(:email_notify_on_new_inbox)

    if current_user.update(update_params)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to edit_user_notifications_path
  end
  # }}}
end
