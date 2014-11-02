class UserController < ApplicationController
  def show
    @user = User.find_by_screen_name(params[:username])
  end

  def edit
  end
end
