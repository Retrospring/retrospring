class UserController < ApplicationController
  include ThemeHelper

  before_action :authenticate_user!, only: %w(edit update edit_privacy update_privacy edit_theme update_theme preview_theme delete_theme data export begin_export)

  def show
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @answers = @user.cursored_answers(last_id: params[:last_id])
    @answers_last_id = @answers.map(&:id).min
    @more_data_available = !@user.cursored_answers(last_id: @answers_last_id, size: 1).count.zero?

    if user_signed_in?
      notif = Notification.where(target_type: "Relationship", target_id: @user.active_relationships.where(target_id: current_user.id).pluck(:id), recipient_id: current_user.id, new: true).first
      unless notif.nil?
        notif.new = false
        notif.save
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # region Account settings
  def edit
  end

  def update
    user_attributes = params.require(:user).permit(:display_name, :profile_picture, :profile_header, :motivation_header, :website,
                                                   :location, :bio, :show_foreign_themes)
    if current_user.update_attributes(user_attributes)
      text = t('flash.user.update.text')
      text += t('flash.user.update.avatar') if user_attributes[:profile_picture]
      text += t('flash.user.update.header') if user_attributes[:profile_header]
      flash[:success] = text
    else
      flash[:error] = t('flash.user.update.error')
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
    if current_user.update_attributes(user_attributes)
      flash[:success] = t('flash.user.update_privacy.success')
    else
      flash[:error] = t('flash.user.update_privacy.error')
    end
    redirect_to edit_user_privacy_path
  end
  # endregion

  # region Groups
  def groups
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @groups = if current_user == @user
                @user.groups
              else
                @user.groups.where(private: false)
              end.all
  end
  # endregion

  def followers
    @title = 'Followers'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @users = @user.cursored_followers(last_id: params[:last_id])
    @users_last_id = @users.map(&:id).min
    @more_data_available = !@user.cursored_followers(last_id: @users_last_id, size: 1).count.zero?
    @type = :friend
    render 'show_follow'
  end

  def friends
    @title = 'Following'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @users = @user.cursored_friends(last_id: params[:last_id])
    @users_last_id = @users.map(&:id).min
    @more_data_available = !@user.cursored_friends(last_id: @users_last_id, size: 1).count.zero?
    @type = :friend
    render 'show_follow'
  end

  def questions
    @title = 'Questions'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @questions = @user.cursored_questions(author_is_anonymous: false, last_id: params[:last_id])
    @questions_last_id = @questions.map(&:id).min
    @more_data_available = !@user.cursored_questions(author_is_anonymous: false, last_id: @questions_last_id, size: 1).count.zero?
  end

  def data
  end

  def edit_theme
  end

  def delete_theme
    current_user.theme.destroy!
    redirect_to edit_user_profile_path
  end

  # NOTE: Yes, I am storing and transmitting values as 3 byte numbers because false sense of security.
  def preview_theme
    attrib = params.permit([
      :primary_color, :primary_text,
      :danger_color, :danger_text,
      :success_color, :success_text,
      :warning_color, :warning_text,
      :info_color, :info_text,
      :default_color, :default_text,
      :panel_color, :panel_text,
      :link_color, :background_color,
      :background_text, :background_muted,
      :input_color, :input_text,
      :outline_color
    ])

    attrib.each do |k ,v|
      attrib[k] = v.to_i
    end

    render plain: render_theme_with_context(attrib)
  end

  def update_theme
    update_attributes = params.require(:theme).permit([
      :primary_color, :primary_text,
      :danger_color, :danger_text,
      :success_color, :success_text,
      :warning_color, :warning_text,
      :info_color, :info_text,
      :default_color, :default_text,
      :panel_color, :panel_text,
      :link_color, :background_color,
      :background_text, :background_muted,
      :input_color, :input_text,
      :outline_color
    ])

    if current_user.theme.nil?
      current_user.theme = Theme.new update_attributes
      current_user.theme.user_id = current_user.id

      if current_user.theme.save
        flash[:success] = 'Theme saved.'
      else
        flash[:error] = 'Theme saving failed. ' + current_user.theme.errors.messages.flatten.join(' ')
      end
    elsif current_user.theme.update_attributes(update_attributes)
      flash[:success] = 'Theme saved.'
    else
      flash[:error] = 'Theme saving failed. ' + current_user.theme.errors.messages.flatten.join(' ')
    end
    redirect_to edit_user_theme_path
  end

  def export
    if current_user.export_processing
      flash[:info] = 'An export is currently in progress for this account.'
    end
  end

  def begin_export
    if current_user.can_export?
      ExportWorker.perform_async(current_user.id)
      flash[:success] = 'Your account is currently being exported.  This will take a little while.'
    else
      flash[:error] = 'Nice try, kid.'
    end

    redirect_to user_export_path
  end
end
