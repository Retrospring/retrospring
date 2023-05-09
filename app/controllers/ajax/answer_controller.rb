# frozen_string_literal: true

require "cgi"

class Ajax::AnswerController < AjaxController
  include SocialHelper::TwitterMethods
  include SocialHelper::TumblrMethods
  include SocialHelper::TelegramMethods

  def create
    params.require :id
    params.require :answer
    params.require :inbox

    inbox = (params[:inbox] == "true")

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

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true

    @response[:sharing] = sharing_hash(answer) if current_user.sharing_enabled

    return if inbox

    # this assign is needed because shared/_answerbox relies on it, I think
    @question = 1
    @response[:render] = render_to_string(partial: "answerbox", locals: { a: answer, show_question: false, subscribed_answer_ids: [answer.id] })
  end

  def destroy
    params.require :answer

    answer = Answer.find(params[:answer])

    unless (current_user == answer.user) || (privileged? answer.user)
      @response[:status] = :nopriv
      @response[:message] = t(".nopriv")
      return
    end

    Inbox.create!(user: answer.user, question: answer.question, new: true, returning: true) if answer.user == current_user
    answer.destroy

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end

  private

  def sharing_hash(answer) = {
    twitter:  twitter_share_url(answer),
    tumblr:   tumblr_share_url(answer),
    telegram: telegram_share_url(answer),
    custom:   CGI.escape(prepare_tweet(answer)),
  }
end
