class UserController < ApplicationController
  before_filter :authenticate_user!, only: %w(edit update edit_privacy update_privacy)

  def show
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @answers = @user.answers.reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # region Account settings
  def edit
  end

  def update
    user_attributes = params.require(:user).permit(:display_name, :profile_picture, :motivation_header, :website,
                                                   :location, :bio, :crop_x, :crop_y, :crop_w, :crop_h)
    if current_user.update_attributes(user_attributes)
      text = 'Your profile has been updated!'
      text += ' It might take a few minutes until your new profile picture is shown everywhere.' if user_attributes[:profile_picture]
      flash[:success] = text
    else
      flash[:error] = 'An error occurred. ;_;'
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
      flash[:success] = 'Your privacy settings have been updated!'
    else
      flash[:error] = 'An error occurred. ;_;'
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
    @users = @user.followers.reverse_order.paginate(page: params[:page])
    @type = :friend
    render 'show_follow'
  end

  def friends
    @title = 'Following'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @users = @user.friends.reverse_order.paginate(page: params[:page])
    @type = :friend
    render 'show_follow'
  end

  def questions
    @title = 'Questions'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @questions = @user.questions.where(author_is_anonymous: false).reverse_order.paginate(page: params[:page])
  end
end
