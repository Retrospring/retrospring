# frozen_string_literal: true

class AjaxController < ApplicationController
  skip_before_action :find_active_announcements
  before_action :build_response
  after_action :return_response

  respond_to :json

  unless Rails.env.development?
    rescue_from(StandardError) do |e|
      Sentry.capture_exception(e)

      @response = {
        success: false,
        message: t("errors.base"),
        status:  :err
      }

      return_response
    end
  end

  rescue_from(Errors::Base) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: e.message,
      status:  e.code
    }

    return_response
  end

  rescue_from(KeyError) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: t("errors.parameter_error", parameter: e.key),
      status:  :err
    }

    return_response
  end

  rescue_from(Dry::Types::CoercionError, Dry::Types::ConstraintError) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: t("errors.invalid_parameter"),
      status:  :err
    }

    return_response
  end

  rescue_from(ActiveRecord::RecordNotFound) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: t("errors.record_not_found"),
      status:  :not_found
    }

    return_response
  end

  rescue_from(ActionController::ParameterMissing) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: t("errors.parameter_error", parameter: e.param.capitalize),
      status:  :parameter_error
    }

    return_response
  end

  rescue_from(Errors::Base) do |e|
    Sentry.capture_exception(e)

    @response = {
      success: false,
      message: I18n.t(e.locale_tag),
      status:  e.code
    }

    return_response
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
    response.status = @status || 200
    response.headers["Content-Type"] = "application/json"
    response.body = @response.to_json
  end
end
