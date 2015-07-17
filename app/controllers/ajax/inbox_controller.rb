class Ajax::InboxController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end
  
  def create
    unless user_signed_in?
      @status = :noauth
      @message = I18n.t('messages.noauth')
      @success = false
      return
    end

    question = Question.create!(content: QuestionGenerator.generate,
                                author_is_anonymous: true,
                                author_name: 'justask',
                                user: current_user)

    inbox = Inbox.create!(user: current_user, question_id: question.id, new: true)

    @status = :okay
    @message = I18n.t('messages.inbox.create.okay')
    @success = true
    @render = render_to_string(partial: 'inbox/entry', locals: { i: inbox })
    inbox.update(new: false)
  end

  def remove
    params.require :id

    inbox = Inbox.find(params[:id])

    unless current_user == inbox.user
      @status = :fail
      @message = I18n.t('messages.inbox.remove.fail')
      @success = false
      return
    end

    begin
      inbox.remove
    rescue
      @status = :err
      @message = I18n.t('messages.error')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.inbox.remove.okay')
    @success = true
  end

  def remove_all
    begin
      Inbox.where(user: current_user).each { |i| i.remove }
    rescue
      @status = :err
      @message = I18n.t('messages.error')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.inbox.remove_all.okay')
    @success = true
    render 'ajax/inbox/remove'
  end

  def remove_all_author
    begin
      @target_user = User.where('LOWER(screen_name) = ?', params[:author].downcase).first!
      @inbox = current_user.inboxes.joins(:question)
                                   .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
      @inbox.each { |i| i.remove }
    rescue
      @status = :err
      @message = I18n.t('messages.error')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.inbox.remove_all.okay')
    @success = true
    render 'ajax/inbox/remove'
  end
end
