# frozen_string_literal: true

class InboxController < ApplicationController
  before_action :authenticate_user!

  before_action :find_author, only: %i[show]

  def show
    @inbox = current_user.cursored_inbox(last_id: params[:last_id]).then(&method(:filter_author_chain))
    @inbox_last_id = @inbox.map(&:id).min
    @more_data_available = !current_user.cursored_inbox(last_id: @inbox_last_id, size: 1).then(&method(:filter_author_chain)).count.zero?
    @inbox_count = current_user.inboxes.then(&method(:filter_author_chain)).count

    @delete_id = if @author_user && @inbox_count.positive?
                   "ib-delete-all-author"
                 else
                   "ib-delete-all"
                 end

    @disabled = true if @inbox.empty?
    respond_to do |format|
      format.html
      format.turbo_stream do
        render "show", layout: false, status: :see_other

        @inbox.update_all(new: false)
      end
    end
  end

  def create
    question = Question.create!(content:             QuestionGenerator.generate,
                                author_is_anonymous: true,
                                author_identifier:   "justask",
                                user:                current_user)

    inbox = Inbox.create!(user: current_user, question_id: question.id, new: true)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.prepend("entries", partial: "inbox/entry", locals: { i: inbox })

        inbox.update(new: false)
      end

      format.html { redirect_to inbox_path }
    end
  end

  private

  def find_author
    return if params[:author].blank?

    @author = params[:author]

    @author_user = User.where("LOWER(screen_name) = ?", @author.downcase).first
    flash.now[:error] = t(".author.error", author: @author) unless @author_user
  end

  def filter_author_chain(query)
    return query unless @author_user

    query
      .joins(:question)
      .where(questions: { user: @author_user, author_is_anonymous: false })
  end
end
