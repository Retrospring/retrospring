class Sleipnir::QuestionAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :question do
    desc "Given question's content"
    throttle hourly: 72
    get "/:id", as: :question_api do
      question = Question.find params["id"]
      if question.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_QUESTION_NOT_FOUND"})
      end
      represent question, with: Sleipnir::Entities::QuestionEntity
    end

    desc "Delete given question"
    oauth2 'write'
    delete '/:id', as: :delete_question_api do
      question = Question.find params[:id]

      if question.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_QUESTION_NOT_FOUND"})
      end

      unless (current_user == question.user) or (privileged? question.user)
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      question.destroy

      status 204
      return
    end

    # NOTE: For compatability,
    # DO NOT UNDER ANY CIRCUMSTANCE REMOVE ANYTHING FROM THIS VARIABLE, ONLY ADD
    SERVICE_FLAGS = %w(twitter tumblr facebook).freeze

    desc "Answer a question"
    oauth2 'write'
    throttle hourly: 720
    params do
      requires :answer, type: String
      optional :share_flags, type: Fixnum, default: 0
    end
    post '/:id', as: :answer_question_api do
      question = Question.find params["id"]
      if question.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_QUESTION_NOT_FOUND"})
      end

      if current_user.answered? question
        status 400
        return present({success: false, code: 400, result: "ERR_ALREADY_ANSWERED"})
      end

      inbox = Inbox.find_by question: question
      if inbox.nil? and not question.user.privacy_allow_stranger_answers
        status 403
        return present({success: false, code: 403, result: "ERR_MUST_INBOX"})
      end

      answer = if inbox.nil?
        current_user.answer question, params[:answer], current_application
      else
        inbox.answer params[:answer], current_user, current_application
      end

      services = []
      SERVICE_FLAGS.each_with_index do |svc, index|
        services.push svc if (params[:share_flags] & (2 ** index)) > 0
      end

      ShareWorker.perform_async(current_user.id, answer.id, services) if services.count > 0

      code = if services.length > 0
        202
      else
        201
      end
      status code
      present({success: true, code: code, result: "SUCCESS_ANSWERED"})
    end

    desc "Given question's answers"
    throttle hourly: 72
    get "/:id/answers", as: :question_api do
      collection = since_id Answer, "question_id = ?", params["id"]
      represent_collection collection, with: Sleipnir::Entities::AnswersEntity
    end
  end
end
