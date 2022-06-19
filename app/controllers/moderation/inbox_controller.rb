# frozen_string_literal: true

class Moderation::InboxController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find_by(screen_name: params[:user])
    @inboxes = @user.cursored_inbox(last_id: params[:last_id])
    @inbox_last_id = @inboxes.map(&:id).min
    @more_data_available = !@user.cursored_inbox(last_id: @inbox_last_id, size: 1).count.zero?
    @inbox_count = @user.inboxes.count

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end
end
