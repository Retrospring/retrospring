class PublicController < ApplicationController
  before_filter :authenticate_user!

  def index
    @timeline = Answer.all.reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
