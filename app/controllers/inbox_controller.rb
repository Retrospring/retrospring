class InboxController < ApplicationController
  def show
    @inbox = Inbox.where(user: current_user).order(:created_at).reverse_order
  end
end
