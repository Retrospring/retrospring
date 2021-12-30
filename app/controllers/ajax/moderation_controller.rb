require 'use_case/user/ban'
require 'use_case/user/unban'
require 'errors'

class Ajax::ModerationController < AjaxController
  def vote
    params.require :id
    params.require :upvote

    report = Report.find(params[:id])

    begin
      current_user.report_vote(report, params[:upvote])
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.moderation.vote.fail')
      return
    end

    @response[:count] = report.votes
    @response[:status] = :okay
    @response[:message] = I18n.t('messages.moderation.vote.okay')
    @response[:success] = true
  end

  def destroy_vote
    params.require :id

    report = Report.find(params[:id])

    begin
      current_user.report_unvote report
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.moderation.destroy_vote.fail')
      return
    end

    @response[:count] = report.votes
    @response[:status] = :okay
    @response[:message] = I18n.t('messages.moderation.destroy_vote.okay')
    @response[:success] = true
  end

  def destroy_report
    params.require :id

    report = Report.find(params[:id])

    begin
      report.deleted = true
      report.save
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.moderation.destroy_report.fail')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.moderation.destroy_report.okay')
    @response[:success] = true
  end

  def create_comment
    params.require :id
    params.require :comment

    report = Report.find(params[:id])


    begin
      current_user.report_comment(report, params[:comment])
    rescue ActiveRecord::RecordInvalid => e
      Sentry.capture_exception(e)
      @response[:status] = :rec_inv
      @response[:message] = I18n.t('messages.moderation.create_comment.rec_inv')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.moderation.create_comment.okay')
    @response[:success] = true
    @response[:render] = render_to_string(partial: 'moderation/discussion', locals: { report: report })
    @response[:count] = report.moderation_comments.all.count
  end

  def destroy_comment
    params.require :comment

    @response[:status] = :err
    comment = ModerationComment.find(params[:comment])

    unless current_user == comment.user
      @response[:status] = :nopriv
      @response[:message] = I18n.t('messages.moderation.destroy_comment.nopriv')
      return
    end

    comment.destroy

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.moderation.destroy_comment.okay')
    @response[:success] = true
  end

  def ban
    @response[:status] = :err
    @response[:message] = I18n.t('messages.moderation.ban.error')

    params.require :user
    params.require :ban

    duration = params[:duration].to_i
    duration_unit = params[:duration_unit].to_s
    reason = params[:reason].to_s
    target_user = User.find_by_screen_name!(params[:user])
    unban  = params[:ban] == '0'
    perma  = params[:duration].blank?

    if !unban && target_user.has_role?(:administrator)
      @response[:status] = :nopriv
      @response[:message] = I18n.t('messages.moderation.ban.nopriv')
      return
    end

    if unban
      UseCase::User::Unban.call(target_user.id)
      @response[:message] = I18n.t('messages.moderation.ban.unban')
      @response[:success] = true
      @response[:status]  = :okay
      return
    elsif perma
      @response[:message] = I18n.t('messages.moderation.ban.perma')
      expiry = nil
    else
      params.require :duration
      params.require :duration_unit

      raise Errors::InvalidBanDuration unless %w[hours days weeks months].include? duration_unit

      expiry = DateTime.now + duration.public_send(duration_unit)
      @response[:message] = I18n.t('messages.moderation.ban.temp', date: expiry.to_s)
    end

    UseCase::User::Ban.call(
      target_user_id: target_user.id,
      expiry: expiry,
      reason: reason,
      source_user_id: current_user.id)

    target_user.save!

    @response[:status] = :okay
    @response[:success] = true
  end

  def privilege
    @response[:status] = :err

    params.require :user
    params.require :type
    params.require :status

    status = params[:status] == 'true'

    target_user = User.find_by_screen_name!(params[:user])

    @response[:message] = I18n.t('messages.moderation.privilege.nope')
    return unless %w(moderator admin).include? params[:type].downcase

    unless current_user.has_role?(:administrator)
      @response[:status] = :nopriv
      @response[:message] = I18n.t('messages.moderation.privilege.nopriv')
      return
    end

    @response[:checked] = status
    type = params[:type].downcase
    target_role = {'admin' => 'administrator'}.fetch(type, type).to_sym

    if status
      target_user.add_role target_role
    else
      target_user.remove_role target_role
    end
    target_user.save!

    @response[:message] = I18n.t('messages.moderation.privilege.checked', privilege: params[:type])

    @response[:status] = :okay
    @response[:success] = true
  end
end
