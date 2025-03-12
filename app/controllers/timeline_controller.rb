# frozen_string_literal: true

class TimelineController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: %i[list]
  before_action :set_lists

  def index
    paginate_timeline { |args| current_user.cursored_timeline(**args) }
  end

  def list
    @title = helpers.list_title(@list)
    paginate_timeline { |args| @list.cursored_timeline(**args, current_user:) }
  end

  def public
    @title = helpers.generate_title(t(".title"))
    paginate_timeline { |args| Answer.cursored_public_timeline(**args, current_user:) }
  end

  private

  def set_list
    @list = current_user.lists.find_by!(name: params[:list_name]) if params[:list_name].present?
  end

  def set_lists
    @lists = current_user.lists
    @lists = @lists.where.not(id: @list.id) if @list.present?
  end

  def paginate_timeline
    @timeline = yield(last_id: params[:last_id])
    timeline_ids = @timeline.select("answers.id").map(&:id)
    @timeline_last_id = timeline_ids.min
    @more_data_available = !yield(last_id: @timeline_last_id, size: 1).select("answers.id").count.zero?

    respond_to do |format|
      format.html { render "timeline/timeline" }
      format.turbo_stream { render "timeline/timeline", layout: false, status: :see_other }
    end
  end
end
