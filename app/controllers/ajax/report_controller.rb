# frozen_string_literal: true

class Ajax::ReportController < AjaxController
  def create
    params.require :id
    params.require :type

    @response[:status] = :err

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = t(".noauth")
      return
    end

    result = UseCase::Report::Create.call(
      reporter_id: current_user.id,
      object_id:   params[:id],
      object_type: params[:type],
      reason:      params[:reason],
    )

    if result[:status] == 201
      @response[:status] = :okay
      @response[:message] = t(".success", parameter: params[:type].titleize)
      @response[:success] = true
    else
      @response[:message] = t(".error")
    end
  end
end
