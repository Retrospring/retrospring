class Ajax::QuestionController < ApplicationController
  def create
    params.require :question
    params.require :anonymousQuestion
    params.require :rcpt



    Question.create(content: params[:question],
                    author_is_anonymous: params[:anonymousQuestion])

    @status = :okay
    @message = "Question asked successfully."
    @success = true
  end
end
