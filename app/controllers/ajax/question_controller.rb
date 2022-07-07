# frozen_string_literal: true

require "errors"
require "use_case/question/create"
require "use_case/question/create_followers"
require "use_case/question/destroy"

class Ajax::QuestionController < AjaxController
  def destroy
    params.require :question

    UseCase::Question::Destroy.call(
      question_id:  params[:question],
      current_user: current_user
    )

    @response[:status] = :okay
    @response[:message] = t(".success")
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
      message: t(".success"),
      status:  :okay
    }

    if user_signed_in? && params[:rcpt] == "followers"
      UseCase::Question::CreateFollowers.call(
        source_user_id:    current_user.id,
        content:           params[:question],
        author_identifier: AnonymousBlock.get_identifier(request.ip)
      )
      return
    end

    UseCase::Question::Create.call(
      source_user_id:    user_signed_in? ? current_user.id : nil,
      target_user_id:    params[:rcpt],
      content:           params[:question],
      anonymous:         params[:anonymousQuestion],
      author_identifier: AnonymousBlock.get_identifier(request.ip)
    )
  end
end
