class UserController < ApplicationController
  def show
    @user = User.find_by_screen_name!(params[:username])
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
    @user = User.find_by_screen_name!(params[:username])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def following
    @title = 'Following'
    @user = User.find_by_screen_name!(params[:username])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
end
