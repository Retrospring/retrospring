# frozen_string_literal: true

class Ajax::AnonymousBlockController < AjaxController
  def create
    params.require :question

    question = Question.find(params[:question])

    raise Errors::Forbidden if params[:global] && !current_user.has_role?(:moderator)

    AnonymousBlock.create!(
      user:       params[:global] ? nil : current_user,
      identifier: question.author_identifier,
      question:,
    )

    question.inboxes.first.destroy

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end

  def destroy
    params.require :id

    block = AnonymousBlock.find(params[:id])
    if current_user != block.user
      @response[:status] = :nopriv
      @response[:message] = t(".nopriv")
    end

    block.destroy!

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end
end
