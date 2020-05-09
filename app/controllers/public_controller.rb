class PublicController < ApplicationController
  before_action :authenticate_user!

  def index
    @timeline = Answer.cursored_public_timeline(last_id: params[:last_id])
    @timeline_last_id = @timeline.map(&:id).min
    @more_data_available = !Answer.cursored_public_timeline(last_id: @timeline_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end
end
