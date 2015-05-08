class Ajax::ReportController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = "#{param_miss_ex.param.capitalize} is required"
    @success = false
    render partial: "ajax/shared/status"
  end
  
  def create
    params.require :id
    params.require :type

    @status = :err
    @success = false

    if current_user.nil?
      @message = "login required"
      return
    end

    unless %w(answer comment question user).include? params[:type]
      @message = "unknown type"
      return
    end

    object = if params[:type] == 'user'
               User.find_by_screen_name params[:id]
             else
               params[:type].strip.capitalize.constantize.find params[:id]
             end

    if object.nil?
      @message = "Could not find #{params[:type]}"
      return
    end

    current_user.report object, params[:reason]

    @status = :okay
    @message = "#{params[:type].capitalize} reported.  A moderator will decide what happens with the #{params[:type]}."
    @success = true
  end
end
