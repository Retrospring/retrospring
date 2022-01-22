# frozen_string_literal: true

class FeedbackController < ApplicationController
  before_action :authenticate_user!
  before_action :feature_enabled?
  before_action :canny_consent_given?, only: %w[features bugs]

  def consent
    redirect_to feedback_bugs_path if current_user.has_role? :canny_consent
  end

  def update
    return unless params[:consent] == "true"

    current_user.add_role :canny_consent
    redirect_to feedback_bugs_path
  end

  def features; end

  def bugs; end

  private

  def feature_enabled?
    redirect_to root_path if APP_CONFIG["canny"].nil?
  end

  def canny_consent_given?
    redirect_to feedback_consent_path unless current_user.has_role? :canny_consent
  end
end
