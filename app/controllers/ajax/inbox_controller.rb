class Ajax::InboxController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = "#{param_miss_ex.param.capitalize} is required"
    @success = false
    render partial: "ajax/shared/status"
  end
  
  def create
    unless user_signed_in?
      @status = :noauth
      @message = "requires authentication"
      @success = false
      return
    end

    question = Question.create!(content: QuestionGenerator.generate,
                                author_is_anonymous: true,
                                author_name: 'justask',
                                user: current_user)

    inbox = Inbox.create!(user: current_user, question_id: question.id, new: true)

    @status = :okay
    @message = "Successfully added new question."
    @success = true
    @render = render_to_string(partial: 'inbox/entry', locals: { i: inbox })
    inbox.update(new: false)
  end

  def remove
    params.require :id

    inbox = Inbox.find(params[:id])

    unless current_user == inbox.user
      @status = :fail
      @message = "question not in your inbox"
      @success = false
      return
    end

    begin
      inbox.remove
    rescue
      @status = :err
      @message = "An error occurred"
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully deleted question."
    @success = true
  end

  def remove_all
    begin
      Inbox.where(user: current_user).each { |i| i.remove }
    rescue
      @status = :err
      @message = "An error occurred"
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully deleted questions."
    @success = true
    render 'ajax/inbox/remove'
  end
end
