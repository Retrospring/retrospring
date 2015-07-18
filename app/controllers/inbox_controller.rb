class InboxController < ApplicationController
  before_filter :authenticate_user!

  def show
    @inbox = Inbox.where(user: current_user)
                  .order(:created_at).reverse_order
                  .paginate(page: params[:page])
    @inbox_count = Inbox.where(user: current_user).count
    if params[:author].present?
      begin
        @author = true
        @target_user = User.where('LOWER(screen_name) = ?', params[:author].downcase).first!
        @inbox_author = current_user.inboxes.joins(:question)
                                            .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
                                            .paginate(page: params[:page])
        @inbox_author_count = current_user.inboxes.joins(:question)
                                                  .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
                                                  .count
        if @inbox_author.empty?
          @empty = true
          flash.now[:info] = "No questions from @#{params[:author]} found, showing default entries instead!"
        else
          @inbox = @inbox_author
          @inbox_count = @inbox_author_count
        end
      rescue
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
      format.js
    end
  end
end
