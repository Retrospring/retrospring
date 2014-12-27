class UserController < ApplicationController
  def show
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).first!
    @answers = @user.answers.reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    authenticate_user!
  end

  def update
    authenticate_user!
    user_attributes = params.require(:user).permit(:display_name, :motivation_header, :website, :location, :bio)
    unless current_user.update_attributes(user_attributes)
      flash[:error] = 'fork it'
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
