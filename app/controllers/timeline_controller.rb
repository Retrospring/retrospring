# frozen_string_literal: true

class TimelineController < ApplicationController
  before_action :authenticate_user!

  def index
    paginate_timeline { |args| current_user.cursored_timeline(**args) }
  end

  def list
    @list = current_user.lists.find_by!(name: params[:list_name])
    @title = list_title(current_user.lists.find_by!(name: params[:list_name]))
    paginate_timeline { |args| @list.cursored_timeline(**args) }
  end

  def public
    @title = generate_title(t(".title"))
    paginate_timeline { |args| Answer.cursored_public_timeline(**args) }
  end

  private

  def paginate_timeline
    @timeline = yield(last_id: params[:last_id])
    @timeline_last_id = @timeline.map(&:id).min
    @more_data_available = !yield(last_id: @timeline_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html { render "timeline/timeline" }
      format.js { render "timeline/timeline", layout: false }
    end
  end
end
