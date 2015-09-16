class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @type = params[:type]
    @notifications = if @type == 'all'
                       Notification.for(current_user)
                     elsif @type == 'new'
                       Notification.for(current_user).where(new: true)
                     else
                       Notification.for(current_user).where('LOWER(target_type) = ?', @type)
                     end.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
