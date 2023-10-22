# frozen_string_literal: true

class QuestionComponent < ApplicationComponent
  include ApplicationHelper
  include BootstrapHelper
  include UserHelper

  def initialize(question:, context_user: nil, collapse: true, hide_avatar: false, profile_question: false)
    @question = question
    @context_user = context_user
    @collapse = collapse
    @hide_avatar = hide_avatar
    @profile_question = profile_question
  end

  private

  def author_identifier = @question.author_is_anonymous ? @question.author_identifier : nil

  def follower_question? = !@question.author_is_anonymous && !@question.direct && @question.answer_count.positive?

  def hide_avatar? = @hide_avatar || @question.author_is_anonymous
end
