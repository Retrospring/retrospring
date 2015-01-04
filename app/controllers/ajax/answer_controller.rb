class Ajax::AnswerController < ApplicationController
  def create
    params.require :id
    params.require :answer
    params.require :share
    params.require :inbox

    inbox = (params[:inbox] == 'true')

    if inbox
      inbox_entry = Inbox.find(params[:id])

      unless current_user == inbox_entry.user
        @status = :fail
        @message = "question not in your inbox"
        @success = false
        return
      end
    else
      question = Question.find(params[:id])

      unless question.user.privacy_allow_stranger_answers
        @status = :privacy_stronk
        @message = "This user does not want other users to answer their question."
        @success = false
        return
      end
    end

    answer = nil

    begin
      answer = if inbox
                 inbox_entry.answer params[:answer], current_user
               else
                 current_user.answer question, params[:answer]
               end
    rescue
      @status = :err
      @message = "An error occurred"
      @success = false
      return
    end

    services = JSON.parse params[:share]
    ShareWorker.perform_async(current_user.id, answer.id, services)


    @status = :okay
    @message = "Successfully answered question."
    @success = true
    unless inbox
      @question = 1
      @render = render_to_string(partial: 'shared/answerbox', locals: { a: answer, show_question: false })
    end
  end

  def destroy
    params.require :answer

    answer = Answer.find(params[:answer])

    unless (current_user == answer.user) or (privileged? answer.user)
      @status = :nopriv
      @message = "can't delete other people's answers"
      @success = false
      return
    end

    if answer.user == current_user
      Inbox.create!(user: answer.user, question: answer.question, new: true)
    end # TODO: decide what happens with the question
    answer.destroy

    @status = :okay
    @message = "Successfully deleted answer."
    @success = true
  end
end
