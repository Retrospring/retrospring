class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @type = params[:type]
    @notifications = if @type == 'all'
                       Notification.for(current_user)
                     else
                       Notification.for(current_user).where('LOWER(target_type) = ?', @type)
                     end
  end
end
