# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  TYPE_MAPPINGS = {
    "answer"       => Notification::QuestionAnswered.name,
    "comment"      => Notification::Commented.name,
    "commentsmile" => Notification::CommentSmiled.name,
    "relationship" => Notification::StartedFollowing.name,
    "smile"        => Notification::Smiled.name
  }.freeze

  def index
    @type = TYPE_MAPPINGS[params[:type]] || params[:type]
    @notifications = cursored_notifications_for(type: @type, last_id: params[:last_id])
    paginate_notifications
    @counters = count_unread_by_type
    mark_notifications_as_read

    respond_to do |format|
      format.html
      format.turbo_stream { render layout: false, status: :see_other }
    end
  end

  def read
    current_user.notifications.where(new: true).update_all(new: false) # rubocop:disable Rails/SkipsModelValidations
    current_user.touch(:notifications_updated_at)

    respond_to do |format|
      format.turbo_stream do
        render "navigation/notifications", locals: { notifications: [], notification_count: nil }
      end
    end
  end

  private

  def paginate_notifications
    @notifications_last_id = @notifications.map(&:id).min
    @more_data_available = !cursored_notifications_for(type: @type, last_id: @notifications_last_id, size: 1).count.zero?
  end

  def count_unread_by_type
    Notification.where(recipient: current_user, new: true)
                .group(:target_type)
                .count(:target_type)
  end

  # rubocop:disable Rails/SkipsModelValidations
  def mark_notifications_as_read
    # using .dup to not modify @notifications -- useful in tests
    updated = @notifications&.dup&.update_all(new: false)
    current_user.touch(:notifications_updated_at) if updated.positive?
  end
  # rubocop:enable Rails/SkipsModelValidations

  def cursored_notifications_for(type:, last_id:, size: nil)
    cursor_params = { last_id: last_id, size: size }.compact

    case type
    when "all"
      Notification.cursored_for(current_user, **cursor_params)
    when "new"
      Notification.cursored_for(current_user, new: true, **cursor_params)
    else
      Notification.cursored_for_type(current_user, type, **cursor_params)
    end
  end
end
