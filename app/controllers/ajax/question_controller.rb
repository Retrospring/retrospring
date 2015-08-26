class Ajax::QuestionController < ApplicationController
  include MarkdownHelper

  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end

  def destroy
    params.require :question

    question = Question.find params[:question]
    if question.nil?
      @status = :not_found
      @message = I18n.t('messages.question.destroy.not_found')
      @success = false
      return
    end

    if not (current_user.mod? or question.user == current_user)
      @status = :not_authorized
      @message = I18n.t('messages.question.destroy.not_authorized')
      @success = false
      return
    end

    question.destroy!

    @status = :okay
    @message = I18n.t('messages.question.destroy.okay')
    @success = true
  end

  def create
    params.require :question
    params.require :anonymousQuestion
    params.require :rcpt

    begin
      question = Question.create!(content: params[:question],
                                  author_is_anonymous: params[:anonymousQuestion],
                                  user: current_user)
    rescue ActiveRecord::RecordInvalid
      @status = :rec_inv
      @message = I18n.t('messages.question.create.rec_inv')
      @success = false
      return
    end

    unless current_user.nil?
      current_user.increment! :asked_count unless params[:anonymousQuestion] == 'true'
    end

    if params[:rcpt] == 'followers'
      unless current_user.nil?
        QuestionWorker.perform_async params[:rcpt], current_user.id, question.id
      end
    elsif params[:rcpt].start_with? 'grp:'
      unless current_user.nil?
        begin
          current_user.groups.find_by_name!(params[:rcpt].sub 'grp:', '')
          QuestionWorker.perform_async params[:rcpt], current_user.id, question.id
        rescue ActiveRecord::RecordNotFound
          @status = :not_found
          @message = I18n.t('messages.question.create.not_found')
          @success = false
          return
        end
      end
    else
      if User.find(params[:rcpt]).nil?
        @status = :not_found
        @message = I18n.t('messages.question.create.not_found')
        @success = false
        return
      end

      Inbox.create!(user_id: params[:rcpt], question_id: question.id, new: true)
    end

    @status = :okay
    @message = I18n.t('messages.question.create.okay')
    @success = true
  end

  def preview
    params.require :md

    @message = I18n.t('messages.question.preview.fail')
    begin
      @markdown = markdown params[:md]
      @message = I18n.t('messages.question.preview.okay')
    rescue
      @status = :fail
      @success = false
      return
    end
    @status = :okay
    @success = true
  end
end
