# frozen_string_literal: true

require "use_case/question/create"
require "use_case/question/create_followers"
require "use_case/question/destroy"

class Ajax::QuestionController < AjaxController
  def destroy
    params.require :question

    # set up fake success response -- the use cases raise errors on exceptions
    # which get rescued by the base class
    @response = {
      success: true,
      message: 'Question destroyed successfully.',
      status: :okay
    }

    UseCase::Question::Destroy.call(
      current_user_id: current_user.id,
      question_id: params[:question]
    )
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
