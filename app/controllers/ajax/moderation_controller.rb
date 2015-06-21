class Ajax::ModerationController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end
  
  def vote
    params.require :id
    params.require :upvote

    report = Report.find(params[:id])

    begin
      current_user.report_vote(report, params[:upvote])
    rescue
      @status = :fail
      @message = I18n.t('messages.moderation.vote.fail')
      @success = false
      return
    end

    @count = report.votes
    @status = :okay
    @message = I18n.t('messages.moderation.vote.okay')
    @success = true
  end

  def destroy_vote
    params.require :id

    report = Report.find(params[:id])

    begin
      current_user.report_unvote report
    rescue
      @status = :fail
      @message = I18n.t('messages.moderation.destroy_vote.fail')
      @success = false
      return
    end

    @count = report.votes
    @status = :okay
    @message = I18n.t('messages.moderation.destroy_vote.okay')
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
      @message = I18n.t('messages.moderation.destroy_report.fail')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.moderation.destroy_report.okay')
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
      @message = I18n.t('messages.moderation.create_comment.rec_inv')
      return
    end

    @status = :okay
    @message = I18n.t('messages.moderation.create_comment.okay')
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
      @message = I18n.t('messages.moderation.destroy_comment.nopriv')
      @success = false
      return
    end

    comment.destroy

    @status = :okay
    @message = I18n.t('messages.moderation.destroy_comment.okay')
    @success = true
  end

  def ban
    @status = :err
    @message = I18n.t('messages.moderation.ban.error')
    @success = false

    params.require :user
    params.require :ban
    params.require :permaban

    reason = params[:reason]
    target = User.find_by_screen_name(params[:user])
    unban  = params[:ban] == "0"
    perma  = params[:permaban] == "1"

    buntil = DateTime.strptime params[:until], "%m/%d/%Y %I:%M %p" unless unban or perma

    if not unban and target.admin?
      @status = :nopriv
      @message = I18n.t('messages.moderation.ban.nopriv')
      @success = false
      return
    end

    if unban
      target.unban
      @message = I18n.t('messages.moderation.ban.unban')
      @success = true
    elsif perma
      target.ban nil, reason
      @message = I18n.t('messages.moderation.ban.perma')
    else
      target.ban buntil, reason
      @message = I18n.t('messages.moderation.ban.temp', date: buntil.to_s)
    end
    target.save!

    @status = :okay
    @success = target.banned? == !unban
  end

  def privilege
    @status = :err
    @success = false

    params.require :user
    params.require :type
    params.require :status

    status = params[:status] == 'true'

    target_user = User.find_by_screen_name(params[:user])

    @message = I18n.t('messages.moderation.privilege.nope')
    return unless %w(blogger supporter moderator admin contributor translator).include? params[:type].downcase

    if %w(supporter moderator admin).include?(params[:type].downcase) and !current_user.admin?
      @status = :nopriv
      @message = I18n.t('messages.moderation.privilege.nopriv')
      @success = false
      return
    end

    @checked = status
    target_user.send("#{params[:type]}=", status)
    target_user.save!

    @message = I18n.t('messages.moderation.privilege.checked', privilege: params[:type])

    @status = :okay
    @success = true
  end
end
