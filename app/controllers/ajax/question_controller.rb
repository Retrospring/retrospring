class Ajax::QuestionController < ApplicationController
  def create
    params.require :question
    params.require :anonymousQuestion
    params.require :rcpt

    question = Question.create!(content: params[:question],
                                author_is_anonymous: params[:anonymousQuestion],
                                user: current_user)

    Inbox.create!(user_id: params[:rcpt], question_id: question.id, new: true)

    @status = :okay
    @message = "Question asked successfully."
    @success = true
  end
end
