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

    begin
      question = Question.create!(content: params[:question],
                                  author_is_anonymous: params[:anonymousQuestion],
                                  user: current_user)
    rescue ActiveRecord::RecordInvalid => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :rec_inv
      @response[:message] = I18n.t('messages.question.create.rec_inv')
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
          current_user.groups.find_by_name!(params[:rcpt].sub 'grp:', '')
          QuestionWorker.perform_async params[:rcpt], current_user.id, question.id
        rescue ActiveRecord::RecordNotFound => e
          NewRelic::Agent.notice_error(e)
          @response[:status] = :not_found
          @response[:message] = I18n.t('messages.question.create.not_found')
          return
        end
      end
    else
      if User.find(params[:rcpt]).nil?
        @response[:status] = :not_found
        @response[:message] = I18n.t('messages.question.create.not_found')
        return
      end

      Inbox.create!(user_id: params[:rcpt], question_id: question.id, new: true)
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.question.create.okay')
    @response[:success] = true
  end
end
