# frozen_string_literal: true

class Moderation::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_filter_enabled
  before_action :set_type_options
  before_action :set_last_reports_visit

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

  def show
    @report = Report.find(params[:id])
  end

  private

  def filter_params
    params.slice(*ReportFilter::KEYS).permit(*ReportFilter::KEYS)
  end

  def set_filter_enabled
    @filter_enabled = params.slice(*ReportFilter::KEYS)
                            .reject! { |_, value| value.empty? || value.nil? }
                            .values
                            .any?
  end

  def set_type_options
    @type_options = [
      [t("voc.all"), ""],
      [t("activerecord.models.answer.one"), :answer],
      [t("activerecord.models.comment.one"), :comment],
      [t("activerecord.models.question.one"), :question],
      [t("activerecord.models.user.one"), :user]
    ]
  end

  def set_last_reports_visit
    current_user.last_reports_visit = DateTime.now
    current_user.save
  end
end
