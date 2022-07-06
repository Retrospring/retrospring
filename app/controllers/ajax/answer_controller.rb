class Ajax::AnswerController < AjaxController
  def create
    params.require :id
    params.require :answer
    params.require :share
    params.require :inbox

    inbox = (params[:inbox] == 'true')

    if inbox
      inbox_entry = Inbox.find(params[:id])

      unless current_user == inbox_entry.user
        @response[:status] = :fail
        @response[:message] = t(".error")
        return
      end
    else
      question = Question.find(params[:id])

      unless question.user.privacy_allow_stranger_answers
        @response[:status] = :privacy_stronk
        @response[:message] = t(".privacy")
        return
      end
    end

    answer = if inbox
               inbox_entry.answer params[:answer], current_user
             else
               current_user.answer question, params[:answer]
             end

    services = JSON.parse params[:share]
    services.each do |service|
      ShareWorker.perform_async(current_user.id, answer.id, service)
    end


    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
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
      @response[:message] = t(".nopriv")
      return
    end

    if answer.user == current_user
      Inbox.create!(user: answer.user, question: answer.question, new: true, returning: true)
    end
    answer.destroy

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end
end
