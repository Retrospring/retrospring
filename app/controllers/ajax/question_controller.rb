# frozen_string_literal: true

require "use_case/question/create"
require "use_case/question/create_followers"

class Ajax::QuestionController < AjaxController
  def destroy
    params.require :question

    question = Question.find params[:question]
    if question.nil?
      @response[:status] = :not_found
      @response[:message] = I18n.t('messages.question.destroy.not_found')
      return
    end

    if not (current_user.mod? or question.user == current_user)
      @response[:status] = :not_authorized
      @response[:message] = I18n.t('messages.question.destroy.not_authorized')
      return
    end

    question.destroy!

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.question.destroy.okay')
    @response[:success] = true
  end

  def create
    params.require :question
    params.require :anonymousQuestion
    params.require :rcpt

    # set up fake success response -- the use cases raise errors on exceptions
    # which get rescued by the base class
    @response = {
      success: true,
      message: 'Question asked successfully.',
      status: :okay
    }

    if user_signed_in? && params[:rcpt] == 'followers'
      UseCase::Question::CreateFollowers.call(
        source_user_id: current_user.id,
        content: params[:question]
      )
      return
    end

    UseCase::Question::Create.call(
      source_user_id: user_signed_in? ? current_user.id : nil,
      target_user_id: params[:rcpt],
      content: params[:question],
      anonymous: params[:anonymousQuestion]
    )
  end
end
