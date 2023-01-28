# frozen_string_literal: true

class InboxController < ApplicationController
  before_action :authenticate_user!

  after_action :mark_inbox_entries_as_read, only: %i[show]

  def show
    find_author
    find_inbox_entries
    check_for_empty_filter

    @delete_id = find_delete_id
    @disabled = true if @inbox.empty?
    services = current_user.services

    respond_to do |format|
      format.html { render "show", locals: { services: } }
      format.turbo_stream do
        render "show", locals: { services: }, layout: false, status: :see_other

        # rubocop disabled as just flipping a flag doesn't need to have validations to be run
        @inbox.update_all(new: false) # rubocop:disable Rails/SkipsModelValidations
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

  def check_for_empty_filter
    return unless @author_user && @inbox_count.zero?

    flash[:info] = t(".author.info", author: @author)
    redirect_to inbox_path(last_id: params[:last_id])
  end

  def find_author
    return if params[:author].blank?

    @author = params[:author]

    @author_user = User.where("LOWER(screen_name) = ?", @author.downcase).first
    flash.now[:error] = t(".author.error", author: @author) unless @author_user
  end

  def find_inbox_entries
    @inbox = current_user.cursored_inbox(last_id: params[:last_id]).then(&method(:filter_author_chain))
    @inbox_last_id = @inbox.map(&:id).min
    @more_data_available = current_user.cursored_inbox(last_id: @inbox_last_id, size: 1).then(&method(:filter_author_chain)).count.positive?
    @inbox_count = current_user.inboxes.then(&method(:filter_author_chain)).count
  end

  def find_delete_id
    return "ib-delete-all-author" if @author_user && @inbox_count.positive?

    "ib-delete-all"
  end

  def filter_author_chain(query)
    return query unless @author_user

    query
      .joins(:question)
      .where(questions: { user: @author_user, author_is_anonymous: false })
  end

  def mark_inbox_entries_as_read
    # using .dup to not modify @inbox -- useful in tests
    @inbox&.dup&.update_all(new: false) # rubocop:disable Rails/SkipsModelValidations
  end
end
