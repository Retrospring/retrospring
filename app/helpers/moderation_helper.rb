module ModerationHelper
  # @param report [Report]
  def content_url(report)
    target = report.target
    case report.type
      when 'Reports::Answer'
        show_user_answer_path target.user.screen_name, target.id
      when 'Reports::Comment'
        show_user_answer_path target.answer.user.screen_name, target.answer.id
      when 'Reports::Question'
        show_user_question_path 'user', target.id
      when 'Reports::User'
        show_user_profile_path target.screen_name
      else
        '#'
    end
  end
end
