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
        @target_user = User.find_by_screen_name params[:author]
        @inbox_author = current_user.inboxes.joins(:question)
                                            .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
                                            .paginate(page: params[:page])
        @inbox_author_count = current_user.inboxes.joins(:question)
                                                  .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
                                                  .count
        if @inbox_author.empty?
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

    @disabled = true if @inbox.empty? or @not_found
    respond_to do |format|
      format.html
      format.js
    end
  end
end
