class Ajax::FriendController < ApplicationController
  def create
    @status = :okay
    @message = "Successfully followed user."
    @success = true
  end

  def destroy
    @status = :okay
    @message = "Successfully unfollowed user."
    @success = true
  end
end
