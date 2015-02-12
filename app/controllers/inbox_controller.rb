class InboxController < ApplicationController
  before_filter :authenticate_user!

  def show
    @inbox = Inbox.where(user: current_user).order(:created_at).reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
