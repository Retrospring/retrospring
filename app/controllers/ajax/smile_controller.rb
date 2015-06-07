class Ajax::SmileController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end
  
  def create
    params.require :id

    answer = Answer.find(params[:id])

    begin
      current_user.smile answer
    rescue
      @status = :fail
      @message = I18n.t('messages.smile.create.fail')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.smile.create.okay')
    @success = true
  end

  def destroy
    params.require :id

    answer = Answer.find(params[:id])

    begin
      current_user.unsmile answer
    rescue
      @status = :fail
      @message = I18n.t('messages.smile.destroy.fail')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.smile.destroy.okay')
    @success = true
  end

  def create_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.smile_comment comment
    rescue
      @status = :fail
      @message = I18n.t('messages.smile.create_comment.fail')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.smile.create_comment.okay')
    @success = true
  end

  def destroy_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.unsmile_comment comment
    rescue
      @status = :fail
      @message = I18n.t('messages.smile.destroy_comment.fail')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.smile.destroy_comment.okay')
    @success = true
  end
end
