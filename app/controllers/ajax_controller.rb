# frozen_string_literal: true

require "errors"

class AjaxController < ApplicationController
  before_action :build_response
  after_action :return_response

  respond_to :json

  rescue_from(StandardError) do |e|
    NewRelic::Agent.notice_error(e)

    @response = {
      success: false,
      message: "Something went wrong",
      status: :err
    }

    return_response
  end

  rescue_from(Errors::Base) do |e|
    NewRelic::Agent.notice_error(e)

    @response = {
      success: false,
      message: e.message,
      status: e.code
    }

    return_response
  end

  rescue_from(Dry::Types::CoercionError) do |e|
    NewRelic::Agent.notice_error(e)

    @response = {
      success: false,
      message: "could not coerce value",
      status: :bad_request
    }

    return_response
  end

  rescue_from(ActiveRecord::RecordNotFound) do |e|
    NewRelic::Agent.notice_error(e)

    @response = {
      success: false,
      message: "Record not found",
      status: :not_found
    }

    return_response
  end

  rescue_from(ActiveRecord::RecordInvalid) do |e|
    NewRelic::Agent.notice_error(e)

    @response = {
      success: false,
      message: "Record invalid",
      status: :rec_inv
    }

    return_response
  end

  rescue_from(ActionController::ParameterMissing) do |e|
    NewRelic::Agent.notice_error(e)

    @response = {
      success: false,
      message: I18n.t('messages.parameter_error', parameter: e.param.capitalize),
      status: :parameter_error
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
      message: '',
      status: 'unknown'
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
