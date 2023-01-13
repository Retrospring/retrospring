# frozen_string_literal: true

class Inbox < ApplicationRecord
  belongs_to :user
  belongs_to :question

  attr_accessor :returning

  before_create do
    raise "User does not want to receive anonymous questions" if !returning &&
      question.author_is_anonymous &&
      (question.author_identifier != "justask") &&
      !user.privacy_allow_anonymous_questions?
  end

  def answer(answer_content, user)
    raise Errors::AnsweringOtherBlockedSelf if question.user&.blocking?(user)
    raise Errors::AnsweringSelfBlockedOther if user.blocking?(question.user)

    answer = user.answer(self.question, answer_content)
    self.destroy
    answer
  end

  def remove
    self.question.destroy if self.question.can_be_removed?
    self.destroy
  end

  def as_push_notification
    {
      type:  :inbox,
      title: I18n.t(
        "frontend.push_notifications.inbox.title",
        user: if question.author_is_anonymous
                user.profile.anon_display_name || APP_CONFIG["anonymous_name"]
              else
                question.user.profile.safe_name
              end
      ),
      icon:  question.author_is_anonymous ? "/icons/maskable_icon_x128.png" : question.user.profile_picture.url(:small),
      body:  question.content.truncate(Question::SHORT_QUESTION_MAX_LENGTH)
    }
  end
end
