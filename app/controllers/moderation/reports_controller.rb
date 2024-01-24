# frozen_string_literal: true

class Moderation::ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    filter = ReportFilter.new(filter_params)
    @reports = filter.cursored_results(last_id: params[:last_id])
    @reports_last_id = @reports.map(&:id).min
    @more_data_available = filter.cursored_results(last_id: @reports_last_id, size: 1).count.positive?

    respond_to do |format|
      format.html
      format.turbo_stream { render "index", layout: false, status: :see_other }
    end
  end

  private

  def filter_params
    params.slice(*ReportFilter::KEYS).permit(*ReportFilter::KEYS)
  end

  def list_reports(type:, last_id:, size: nil)
    cursor_params = { last_id:, size: }.compact

    if type == "all"
      Report.cursored_reports(**cursor_params)
    else
      Report.cursored_reports_of_type(type, **cursor_params)
    end
  end
end
