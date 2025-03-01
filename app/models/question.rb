# frozen_string_literal: true

class Question < ApplicationRecord
  include Question::AnswerMethods

  belongs_to :user, optional: true
  has_many :anonymous_blocks, dependent: :nullify
  has_many :answers, dependent: :destroy
  has_many :inbox_entries, dependent: :destroy

  validates :content, length: { minimum: 1 }

  SHORT_QUESTION_MAX_LENGTH = 512
  LONG_QUESTION_MAX_LENGTH = 32768

  before_destroy do
    rep = Report.where(target_id: self.id, type: "Reports::Question")
    rep.each do |r|
      unless r.nil?
        r.resolved = true
        r.save
      end
    end

    # rubocop:disable Rails/SkipsModelValidations
    user&.decrement! :asked_count unless author_is_anonymous || direct
    # rubocop:enable Rails/SkipsModelValidations
  end

  def can_be_removed?
    return false if self.answers.count.positive?
    return false if InboxEntry.where(question: self).count > 1

    true
  end

  def generated? = %w[justask retrospring_exporter].include?(author_identifier)

  def anonymous? = author_is_anonymous && author_identifier.present?

  def long? = content.length > SHORT_QUESTION_MAX_LENGTH
end
