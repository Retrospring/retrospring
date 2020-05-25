class Ajax::QuestionController < AjaxController
  def destroy
    params.require :question

    question = Question.find params[:question]
    if question.nil?
      @response[:status] = :not_found
      @response[:message] = I18n.t('messages.question.destroy.not_found')
      return
    end

    if not (current_user.mod? or question.user == current_user)
      @response[:status] = :not_authorized
      @response[:message] = I18n.t('messages.question.destroy.not_authorized')
      return
    end

    question.destroy!

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.question.destroy.okay')
    @response[:success] = true
  end

  def create
    params.require :question
    params.require :anonymousQuestion
    params.require :rcpt

    is_never_anonymous = user_signed_in? && (params[:rcpt].start_with?('grp:') || params[:rcpt] == 'followers')

    begin
      question = Question.create!(content: params[:question],
                                  author_is_anonymous: is_never_anonymous ? false : params[:anonymousQuestion],
                                  user: current_user)
    rescue ActiveRecord::RecordInvalid => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :rec_inv
      @response[:message] = I18n.t('messages.question.create.rec_inv')
      return
    end

    if !user_signed_in? && !question.author_is_anonymous
      question.delete
      return
    end

    unless current_user.nil?
      current_user.increment! :asked_count unless params[:anonymousQuestion] == 'true'
    end

    if params[:rcpt] == 'followers'
      unless current_user.nil?
        QuestionWorker.perform_async params[:rcpt], current_user.id, question.id
      end
    elsif params[:rcpt].start_with? 'grp:'
      unless current_user.nil?
        begin
          current_user.lists.find_by_name!(params[:rcpt].sub 'grp:', '')
          QuestionWorker.perform_async params[:rcpt], current_user.id, question.id
        rescue ActiveRecord::RecordNotFound => e
          NewRelic::Agent.notice_error(e)
          question.delete
          @response[:status] = :not_found
          @response[:message] = I18n.t('messages.question.create.not_found')
          return
        end
      end
    else
      u = User.find_by_id(params[:rcpt])
      if u.nil?
        @response[:status] = :not_found
        @response[:message] = I18n.t('messages.question.create.not_found')
        question.delete
        return
      end

      if !u.privacy_allow_anonymous_questions && question.author_is_anonymous
        question.delete
        return
      end

      Inbox.create!(user_id: u.id, question_id: question.id, new: true)
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.question.create.okay')
    @response[:success] = true
  end
end
