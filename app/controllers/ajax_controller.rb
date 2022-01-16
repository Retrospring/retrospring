# frozen_string_literal: true

class AjaxController < ApplicationController
  before_action :build_response
  after_action :return_response

  respond_to :json

  rescue_from(StandardError) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: "Something went wrong",
      status:  :err
    }

    return_response
  end

  rescue_from(KeyError) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: "Missing parameter: #{e.key}",
      status:  :err
    }

    return_response
  end

  rescue_from(Dry::Types::CoercionError, Dry::Types::ConstraintError) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: "Invalid parameter",
      status:  :err
    }

    return_response
  end

  rescue_from(ActiveRecord::RecordNotFound) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: "Record not found",
      status:  :not_found
    }

    return_response
  end

  rescue_from(ActionController::ParameterMissing) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: I18n.t("messages.parameter_error", parameter: e.param.capitalize),
      status:  :parameter_error
    }

    return_response
  end

  def find_active_announcements
    # We do not need announcements here
  end

  private

  def build_response
    @response = {
      success: false,
      message: "",
      status:  "unknown"
    }
  end

  def return_response
    # Q: Why don't we just use render(json:) here?
    # A: Because otherwise Rails wants us to use views, which do not make much sense here.
    #
    # Q: Why do we always return 200?
    # A: Because JQuery might not do things we want it to if we don't.
    response.status = 200
    response.headers["Content-Type"] = "application/json"
    response.body = @response.to_json
  end
end
