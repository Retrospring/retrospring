class PublicController < ApplicationController
  def index
    @timeline = Answer.all.reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
