class PublicController < ApplicationController
  before_filter :authenticate_user!

  def index
    @timeline = Answer.joins(:user).where(users: { privacy_allow_public_timeline: true }).all.reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
