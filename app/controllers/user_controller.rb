class UserController < ApplicationController
  def show
    @user = User.find_by_screen_name!(params[:username])
  end

  def edit
    authenticate_user!
  end

  def update
    authenticate_user!
    user_attributes = params.require(:user).permit(:display_name)
    unless current_user.update_attributes(user_attributes)
      flash[:error] = "fork it"
    end
    redirect_to edit_user_profile_path
  end
end
