class Sleipnir::ReportAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :report do
    desc 'Get reports'
    oauth2 'moderation'
    throttle hourly: 72
    get '/', as: :reports_api do
      unless current_user.mod?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      collection = since_id Report, "deleted = ?", [false]
      represent_collection collection, with: Sleipnir::Entities::ReportsEntity
    end

    desc 'Report a user'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/user/:id', as: :report_user_api do
      object = User.find_by_id params[:id]
      if object.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
      end

      current_user.report object, params[:reason]
      status 201
      return present({success: true, code: 201, result: "SUCCESS_REPORTED_USER"})
    end

    desc 'Report a question'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/question/:id', as: :report_question_api do
      object = Question.find_by_id params[:id]
      if object.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_QUESTION_NOT_FOUND"})
      end

      current_user.report object, params[:reason]
      status 201
      return present({success: true, code: 201, result: "SUCCESS_REPORTED_QUESTION"})
    end

    desc 'Report a comment'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/comment/:id', as: :report_comment_api do
      object = Comment.find_by_id params[:id]
      if object.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_COMMENT_NOT_FOUND"})
      end

      current_user.report object, params[:reason]
      status 201
      return present({success: true, code: 201, result: "SUCCESS_REPORTED_COMMENT"})
    end

    desc 'Report an answer'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/answer/:id', as: :report_answer_api do
      object = Answer.find_by_id params[:id]
      if object.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_ANSWER_NOT_FOUND"})
      end

      current_user.report object, params[:reason]
      status 201
      return present({success: true, code: 201, result: "SUCCESS_REPORTED_ANSWER"})
    end

    desc 'Get a report'
    oauth2 'moderation'
    throttle hourly: 72
    get '/:id', as: :report_api do
      unless current_user.mod?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      report = Report.find_by_id params[:id]
      if report.nil?
        status 404
        return present({success: true, code: 404, result: "ERR_REPORT_NOT_FOUND"})
      end

      represent report, with: Sleipnir::Entities::ReportEntity
    end

    desc 'Delete report'
    oauth2 'write'
    throttle hourly: 72
    delete '/:id', as: :delete_report_api do
      unless privileged?
        status 403
        return present({success: true, code: 403, result: "ERR_USER_NO_PRIV"})
      else
        report = Report.find_by_id params[:id]
        if report.nil?
          status 404
          return present({success: true, code: 404, result: "ERR_REPORT_NOT_FOUND"})
        end

        report.deleted = true
        report.save
        status 204
        return
      end
    end
  end
end
