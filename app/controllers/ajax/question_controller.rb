class Ajax::QuestionController < ApplicationController
  def create
    params.require :question
    params.require :anonymousQuestion
    params.require :rcpt

    question = Question.create!(content: params[:question],
                                author_is_anonymous: params[:anonymousQuestion],
                                user: current_user)

    unless current_user.nil?
      current_user.increment! :asked_count unless params[:anonymousQuestion] == 'true'
    end

    if params[:rcpt] == 'followers'
      unless current_user.nil?
        current_user.followers.each do |f|
          Inbox.create!(user_id: f.id, question_id: question.id, new: true)
        end
      end
    else
      Inbox.create!(user_id: params[:rcpt], question_id: question.id, new: true)
    end

    @status = :okay
    @message = "Question asked successfully."
    @success = true
  end
end
