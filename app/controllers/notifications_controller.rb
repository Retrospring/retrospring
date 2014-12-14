class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @type = params[:type]
  end
end
