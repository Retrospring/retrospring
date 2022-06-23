class ModerationController < ApplicationController
  before_action :authenticate_user!

  def index
    @type = params[:type]
    @reports = list_reports(type: @type, last_id: params[:last_id])
    @reports_last_id = @reports.map(&:id).min
    @more_data_available = !list_reports(type: @type, last_id: @reports_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def priority
    @user_id = params[:user_id]
    if @user_id.nil?
      @users = {}
      Report.where(deleted: false).each do |report|
        target = if report.target.is_a? User
          report.target
        elsif report.target.respond_to? :user
          report.target.user
        else
          nil
        end

        next if target.nil?

        @users[target] ||= 0
        @users[target] += 1
      end

      @users = @users.sort_by do |k, v|
        v
      end.reverse

      @users = Hash[@users]
    else
      @user_id = @user_id.to_i
      @type = 'all'
      @reports = []
      Report.where(deleted: false).each do |report|
        if report.target.is_a? User
          @reports.push report if report.target.id == @user_id
        else
          next if report.target.user.nil?
          @reports.push report if report.target.user.id == @user_id
        end
      end

      @target_user = User.find(@user_id)
      render template: 'moderation/index'
    end
  end

  def ip
    @user_id = params[:user_id]
    @host = User.find(@user_id)
    @users = []
    return if @host.nil?
    @users = User.where('(current_sign_in_ip = ? OR last_sign_in_ip = ?) AND id != ?', @host.current_sign_in_ip, @host.last_sign_in_ip, @user_id).to_a
    @users.unshift @host

    render template: 'moderation/priority'
  end

  def toggle_unmask
    session[:moderation_view] = !session[:moderation_view]
    redirect_back fallback_location: root_path
  end

  private

  def list_reports(type:, last_id:, size: nil)
    cursor_params = { last_id: last_id, size: size }.compact

    if type == 'all'
      Report.cursored_reports(**cursor_params)
    else
      Report.cursored_reports_of_type(type, **cursor_params)
    end
  end
end
