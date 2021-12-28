class Ajax::InboxController < AjaxController
  def create
    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    question = Question.create!(content: QuestionGenerator.generate,
                                author_is_anonymous: true,
                                author_name: 'justask',
                                user: current_user)

    inbox = Inbox.create!(user: current_user, question_id: question.id, new: true)

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.inbox.create.okay')
    @response[:success] = true
    @response[:render] = render_to_string(partial: 'inbox/entry', locals: { i: inbox })
    inbox.update(new: false)
  end

  def remove
    params.require :id

    inbox = Inbox.find(params[:id])

    unless current_user == inbox.user
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.inbox.remove.fail')
      return
    end

    begin
      inbox.remove
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :err
      @response[:message] = I18n.t('messages.error')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.inbox.remove.okay')
    @response[:success] = true
  end

  def remove_all
    raise unless user_signed_in?

    begin
      Inbox.where(user: current_user).each { |i| i.remove }
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :err
      @response[:message] = I18n.t('messages.error')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.inbox.remove_all.okay')
    @response[:success] = true
  end

  def remove_all_author
    begin
      @target_user = User.where('LOWER(screen_name) = ?', params[:author].downcase).first!
      @inbox = current_user.inboxes.joins(:question)
                                   .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
      @inbox.each { |i| i.remove }
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :err
      @response[:message] = I18n.t('messages.error')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.inbox.remove_all.okay')
    @response[:success] = true
  end
end
