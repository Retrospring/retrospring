class Ajax::ModerationController < ApplicationController

  def vote
    params.require :id
    params.require :upvote

    report = Report.find(params[:id])

    begin
      current_user.report_vote(report, params[:upvote])
    rescue
      @status = :fail
      @message = "You have already voted on this report."
      @success = false
      return
    end

    @count = report.votes
    @status = :okay
    @message = "Successfully voted on report."
    @success = true
  end

  def destroy_vote
    params.require :id

    report = Report.find(params[:id])

    begin
      current_user.report_unvote report
    rescue
      @status = :fail
      @message = "You have not voted on that report."
      @success = false
      return
    end

    @count = report.votes
    @status = :okay
    @message = "Successfully removed vote from report."
    @success = true
  end

  def destroy_report
    params.require :id

    report = Report.find(params[:id])

    begin
      report.deleted = true
      report.save
    rescue
      @status = :fail
      @message = "Something bad happened!"
      @success = false
      return
    end

    @status = :okay
    @message = "WHERE DID IT GO??? OH NO!!!"
    @success = true
  end

  def create_comment
    params.require :id
    params.require :comment

    report = Report.find(params[:id])

    @success = false

    begin
      current_user.report_comment(report, params[:comment])
    rescue ActiveRecord::RecordInvalid
      @status = :rec_inv
      @message = "Your comment is too long."
      return
    end

    @status = :okay
    @message = "Comment posted successfully."
    @success = true
    @render = render_to_string(partial: 'moderation/discussion', locals: { report: report })
    @count = report.moderation_comments.all.count
  end

  def destroy_comment
    params.require :comment

    @status = :err
    @success = false
    comment = ModerationComment.find(params[:comment])

    unless current_user == comment.user
      @status = :nopriv
      @message = "can't delete other people's comments"
      @success = false
      return
    end

    comment.destroy

    @status = :okay
    @message = "Successfully deleted comment."
    @success = true
  end

  def privilege
    @status = :err
    @success = false

    params.require :user
    params.require :type
    params.require :status

    status = params[:status] == 'true'

    target_user = User.find_by_screen_name(params[:user])

    @message = "nope!"
    return unless %w(banned blogger supporter moderator admin contributor).include? params[:type].downcase

    if (%w(supporter moderator admin).include?(params[:type].downcase) and !current_user.admin?) or
      (params[:type].downcase == 'banned' and target_user.admin?)
      @status = :nopriv
      @message = "You'd better check YOUR privileges first!"
      @success = false
      return
    end

    @checked = status
    target_user.send("#{params[:type]}=", status)
    target_user.save!

    @message = "Successfully checked this user's #{params[:type]} privilege."

    @status = :okay
    @success = true
  end
end
