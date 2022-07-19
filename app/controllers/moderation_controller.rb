class ModerationController < ApplicationController
  before_action :authenticate_user!

  def index
    @type = params[:type]
    @reports = list_reports(type: @type, last_id: params[:last_id])
    @reports_last_id = @reports.map(&:id).min
    @more_data_available = !list_reports(type: @type, last_id: @reports_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def toggle_unmask
    session[:moderation_view] = !session[:moderation_view]
    redirect_back fallback_location: root_path
  end

  private

  def list_reports(type:, last_id:, size: nil)
    cursor_params = { last_id: last_id, size: size }.compact

    if type == 'all'
      Report.cursored_reports(**cursor_params)
    else
      Report.cursored_reports_of_type(type, **cursor_params)
    end
  end
end
