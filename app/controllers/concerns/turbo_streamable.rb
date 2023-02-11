# frozen_string_literal: true

module TurboStreamable
  extend ActiveSupport::Concern

  included do |controller|
    around_action :handle_error, only: controller.respond_to?(:turbo_stream_actions) ? controller.turbo_stream_actions : []
  end

  def render_toast(message, success = true)
    turbo_stream.append("toasts", partial: "shared/toast", locals: { message:, success: })
  end

  class_methods do
    def render_toast = render_toast
  end

  private

  def handle_error
    yield
  rescue Errors::Base => e
    render_error I18n.t(e.locale_tag)
  rescue KeyError, ActionController::ParameterMissing => e
    render_error t("errors.parameter_error", parameter: e.is_a?(KeyError) ? e.key : e.param.capitalize)
  rescue Dry::Types::CoercionError, Dry::Types::ConstraintError
    render_error t("errors.invalid_parameter")
  rescue ActiveRecord::RecordNotFound
    render_error t("errors.record_not_found")
  end

  def render_error(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: render_toast(message, false)
      end
    end
  end
end
