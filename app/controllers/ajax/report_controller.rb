class Ajax::ReportController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end

  def create
    params.require :id
    params.require :type

    @status = :err
    @success = false

    if current_user.nil?
      @message = I18n.t('messages.report.create.login')
      return
    end

    unless %w(answer comment question user).include? params[:type]
      @message = I18n.t('messages.report.create.unknown')
      return
    end

    obj = params[:type].strip.capitalize

    object = case obj
      when 'User'
        User.find_by_screen_name params[:id]
      when 'Question'
        Question.find params[:id]
      when 'Answer'
        Answer.find params[:id]
      when 'Comment'
        Comment.find params[:id]
      else
        Answer.find params[:id]
      end

    if object.nil?
      @message = I18n.t('messages.report.create.not_found', parameter: params[:type])
      return
    end

    current_user.report object, params[:reason]

    @status = :okay
    @message = I18n.t('messages.report.create.okay', parameter: params[:type])
    @success = true
  end
end
