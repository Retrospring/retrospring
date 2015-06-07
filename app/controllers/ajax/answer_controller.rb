class Ajax::AnswerController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |titanic_param|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: titanic_param.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end

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
        @message = I18n.t('messages.answer.create.fail')
        @success = false
        return
      end
    else
      question = Question.find(params[:id])

      unless question.user.privacy_allow_stranger_answers
        @status = :privacy_stronk
        @message = I18n.t('messages.answer.create.privacy_stronk')
        @success = false
        return
      end
    end

    # this should never trigger because empty params throw ParameterMissing
    unless params[:answer].length > 0
      @status = :peter_dinklage
      @message = I18n.t('messages.answer.create.peter_dinklage')
      @success = false
      return
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
      @message = I18n.t('messages.error')
      @success = false
      return
    end

    services = JSON.parse params[:share]
    ShareWorker.perform_async(current_user.id, answer.id, services)


    @status = :okay
    @message = I18n.t('messages.answer.create.okay')
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
      @message = I18n.t('messages.answer.destroy.nopriv')
      @success = false
      return
    end

    if answer.user == current_user
      Inbox.create!(user: answer.user, question: answer.question, new: true)
    end # TODO: decide what happens with the question
    answer.destroy

    @status = :okay
    @message = I18n.t('messages.answer.destroy.okay')
    @success = true
  end
end
