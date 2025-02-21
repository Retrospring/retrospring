# frozen_string_literal: true

class InboxController < ApplicationController
  before_action :authenticate_user!

  def show
    find_inbox_entries

    @delete_id = find_delete_id
    @disabled = true if @inbox.empty?

    mark_inbox_entries_as_read

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    return redirect_to inbox_path if Retrospring::Config.readonly?

    question = Question.create!(content:             QuestionGenerator.generate,
                                author_is_anonymous: true,
                                author_identifier:   "justask",
                                user:                current_user)

    inbox = InboxEntry.create!(user: current_user, question_id: question.id, new: true)
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

  def filter_params
    params.slice(*InboxFilter::KEYS).permit(*InboxFilter::KEYS)
  end

  def find_inbox_entries
    filter = InboxFilter.new(current_user, filter_params)
    @inbox = filter.cursored_results(last_id: params[:last_id])
    @inbox_last_id = @inbox.map(&:id).min
    @more_data_available = filter.cursored_results(last_id: @inbox_last_id, size: 1).count.positive?
    @inbox_count = filter.results.count
  end

  def find_delete_id
    return "ib-delete-all-author" if params[:author].present? && @inbox_count.positive?

    "ib-delete-all"
  end

  # rubocop:disable Rails/SkipsModelValidations
  def mark_inbox_entries_as_read
    # using .dup to not modify @inbox -- useful in tests
    updated = @inbox&.dup&.update_all(new: false)
    current_user.touch(:inbox_updated_at) if updated.positive?
  end
  # rubocop:enable Rails/SkipsModelValidations

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
