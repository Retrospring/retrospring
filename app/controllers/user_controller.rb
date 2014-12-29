class UserController < ApplicationController
  before_filter :authenticate_user!, only: %w(edit update)

  def show
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @answers = @user.answers.reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

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
