class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @type = params[:type]
    @notifications = cursored_notifications_for(type: @type, last_id: params[:last_id])
    @notifications_last_id = @notifications.map(&:id).min
    @more_data_available = !cursored_notifications_for(type: @type, last_id: @notifications_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  private

  def cursored_notifications_for(type:, last_id:, size: nil)
    cursor_params = { last_id: last_id, size: size }.compact

    case type
    when 'all'
      Notification.cursored_for(current_user, **cursor_params)
    when 'new'
      Notification.cursored_for(current_user, new: true, **cursor_params)
    else
      Notification.cursored_for_type(current_user, type, **cursor_params)
    end
  end
end
