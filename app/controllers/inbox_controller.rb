# frozen_string_literal: true

class InboxController < ApplicationController
  before_action :authenticate_user!

  after_action :mark_inbox_entries_as_read, only: %i[show]

  def show # rubocop:disable Metrics/MethodLength
    find_author
    find_inbox_entries

    if @author_user && @inbox_count.zero?
      # rubocop disabled because of a false positive
      flash[:info] = t(".author.info", author: @author) # rubocop:disable Rails/ActionControllerFlashBeforeRender
      redirect_to inbox_path(last_id: params[:last_id])
      return
    end

    @delete_id = find_delete_id
    @disabled = true if @inbox.empty?

    respond_to do |format|
      format.html { render "show" }
      format.turbo_stream do
        render "show", layout: false, status: :see_other

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
    increment_metric

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

  def increment_metric
    Retrospring::Metrics::QUESTIONS_ASKED.increment(
      labels: {
        anonymous: true,
        followers: false,
        generated: true,
      }
    )
  end
end
