# frozen_string_literal: true

class TimelineController < ApplicationController
  before_action :authenticate_user!

  def index
    @timeline = current_user.cursored_timeline(last_id: params[:last_id])
    @timeline_last_id = @timeline.map(&:id).min
    @more_data_available = !current_user.cursored_timeline(last_id: @timeline_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end
end
