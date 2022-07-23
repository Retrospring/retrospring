# frozen_string_literal: true

module ModerationHelper
  # @param report [Report]
  def content_url(report)
    target = report.target
    case report.type
    when "Reports::Answer"
      answer_path target.user.screen_name, target.id
    when "Reports::Comment"
      answer_path target.answer.user.screen_name, target.answer.id
    when "Reports::Question"
      question_path "user", target.id
    when "Reports::User"
      user_path target
    else
      "#"
    end
  end
end
