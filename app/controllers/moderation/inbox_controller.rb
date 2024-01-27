# frozen_string_literal: true

class Moderation::InboxController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find_by(screen_name: params[:user])
    filter = InboxFilter.new(@user, filter_params)

    @inboxes = filter.cursored_results(last_id: params[:last_id])
    @inbox_last_id = @inboxes.map(&:id).min
    @more_data_available = !filter.cursored_results(last_id: @inbox_last_id, size: 1).count.zero?
    @inbox_count = @user.inbox_entries.count

    respond_to do |format|
      format.html
      format.turbo_stream { render "index", layout: false, status: :see_other }
    end
  end

  private

  def filter_params
    params.slice(*InboxFilter::KEYS).permit(*InboxFilter::KEYS)
  end
end
