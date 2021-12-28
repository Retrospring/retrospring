class InboxController < ApplicationController
  before_action :authenticate_user!

  def show
    @inbox = current_user.cursored_inbox(last_id: params[:last_id])
    @inbox_last_id = @inbox.map(&:id).min
    @more_data_available = !current_user.cursored_inbox(last_id: @inbox_last_id, size: 1).count.zero?
    @inbox_count = current_user.inboxes.count

    if params[:author].present?
      begin
        @author = true
        @target_user = User.where('LOWER(screen_name) = ?', params[:author].downcase).first!
        @inbox_author = @inbox.joins(:question)
                              .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
        @inbox_author_count = current_user.inboxes
                                          .joins(:question)
                                          .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
                                          .count

        if @inbox_author.empty?
          @empty = true
          flash.now[:info] = "No questions from @#{params[:author]} found, showing default entries instead!"
        else
          @inbox = @inbox_author
          @inbox_count = @inbox_author_count
          @inbox_last_id = @inbox.map(&:id).min
          @more_data_available = !current_user.cursored_inbox(last_id: @inbox_last_id, size: 1)
                                              .joins(:question)
                                              .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
                                              .count
                                              .zero?
        end
      rescue => e
        Sentry.capture_exception(e)
        flash.now[:error] = "No user with the name @#{params[:author]} found, showing default entries instead!"
        @not_found = true
      end
    end

    if @empty or @not_found
      @delete_id = "ib-delete-all"
    elsif @author
      @delete_id = "ib-delete-all-author"
    else
      @delete_id = "ib-delete-all"
    end

    @disabled = true if @inbox.empty?
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end
end
