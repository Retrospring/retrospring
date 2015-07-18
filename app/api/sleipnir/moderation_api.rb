class Sleipnir::ModerationAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :report do
    desc 'Get report comments'
    oauth2 'moderation'
    throttle hourly: 72
    get '/:id/comment', as: :mod_comments_api do
      unless current_user.mod?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      collection = since_id ModerationComment, 'report_id = ?', [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::ReportCommentsEntity
    end

    desc 'Comment on report'
    oauth2 'write'
    throttle hourly: 72
    params do
      requires :comment, type: String
    end
    post '/:id/comment', as: :mod_comment_api do
      unless privileged?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      report = Report.find(params[:id])
      if report.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_REPORT_NOT_FOUND"})
      end

      current_user.report_comment(report, params[:comment])

      status 201
      return present({success: true, code: 201, result: "COMMENTED"})
    end

    desc 'Delete report comment'
    oauth2 'write'
    throttle hourly: 72
    delete '/:id/comment/:comment_id', as: :delete_mod_comment_api do
      comment = ModerationComment.find(params[:comment_id])
      if comment.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_COMMENT_NOT_FOUND"})
      end

      if !current_scopes.has_scopes?(['moderation']) or comment.user != current_user
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      comment.destroy
      status 204
      return
    end

    desc 'Vote a report up'
    oauth2 'write'
    throttle hourly: 72
    post '/:id/vote', as: :mov_voteup_api do
      unless privileged?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      report = Report.find(params[:id])
      if report.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_REPORT_NOT_FOUND"})
      end

      current_user.report_vote(report, true)

      status 201
      return present({success: true, code: 201, result: "UPVOTED"})
    end

    desc 'Vote a report down'
    oauth2 'write'
    throttle hourly: 72
    delete '/:id/vote', as: :mod_votedown_api do
      unless privileged?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      report = Report.find(params[:id])
      if report.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_REPORT_NOT_FOUND"})
      end

      current_user.report_vote(report, false)

      status 204
      return
    end
  end
end
