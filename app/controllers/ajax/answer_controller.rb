# frozen_string_literal: true

require "use_case/inbox/answer"
require "use_case/question/answer"

class Ajax::AnswerController < AjaxController
  def create
    params.require :id
    params.require :answer
    params.require :share
    params.require :inbox

    # set up fake success response -- the use cases raise errors on exceptions
    # which get rescued by the base class
    @response = {
      success: true,
      message: I18n.t('messages.answer.create.okay'),
      status: :okay
    }

    inbox = (params[:inbox] == 'true')
    services = JSON.parse(params[:share])
    base_use_case_params = {
      current_user_id: current_user.id,
      content: params[:answer],
      share_to_services: services
    }

    answer = if inbox
               UseCase::Inbox::Answer.call(base_use_case_params.merge(inbox_entry_id: params[:id]))
             else
               UseCase::Question::Answer.call(base_use_case_params.merge(question_id: params[:id]))
             end.fetch(:answer)

    unless inbox
      # this assign is needed because shared/_answerbox relies on it, I think
      @question = 1
      @response[:render] = render_to_string(partial: 'answerbox', locals: { a: answer, show_question: false })
    end
  end

  def destroy
    params.require :answer

    answer = Answer.find(params[:answer])

    unless (current_user == answer.user) or (privileged? answer.user)
      @response[:status] = :nopriv
      @response[:message] = I18n.t('messages.answer.destroy.nopriv')
      return
    end

    if answer.user == current_user
      Inbox.create!(user: answer.user, question: answer.question, new: true)
    end # TODO: decide what happens with the question
    answer.destroy

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.answer.destroy.okay')
    @response[:success] = true
  end
end
