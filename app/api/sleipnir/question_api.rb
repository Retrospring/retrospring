class Sleipnir::QuestionAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :question do
    desc "Given question's content"
    # oauth2 'public'
    throttle hourly: 72
    get "/:id", as: :question_api do
      question = Question.find params["id"]
      if question.nil?
        status 404
        return present({success: false, code: 404, reason: "Cannot find question"})
      end
      represent question, with: Sleipnir::Entities::QuestionEntity
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
        return present({success: false, code: 404, reason: "Cannot find question"})
      end

      inbox = Inbox.find_by question: question
      if inbox.nil? and not question.user.privacy_allow_stranger_questions
        status 300
        return present({success: false, code: 300, reason: "User doesn't allow strangers to answer their questions"})
      end

      answer = if inbox.nil?
        current_user.answer question, params[:answer], current_application
      else
        inbox.answer params[:answer], current_user, current_application
      end

      services = []
      SERVICE_FLAGS.each_with_index do |service, index|
        services.push service if (params[:share_flags] & (2 ** index)) > 0
      end

      ShareWorker.perform_async(current_user.id, answer.id, services)

      present({success: true, code: 200, reason: "Answered question ##{params[:id]}"})
    end

    desc "Given question's answers"
    # oauth2 'public'
    throttle hourly: 72
    get "/:id/answers", as: :question_api do
      collection = since_id Answer, "question_id = ?", params["id"]
      represent_collection collection, with: Sleipnir::Entities::AnswersEntity
    end
  end
end
