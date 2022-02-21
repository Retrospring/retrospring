# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  module LocalHelpers
    extend UserHelper
  end

  def new_question_in_inbox(inbox)
    @current_user = inbox.user
    # avoid sending mails immediately if the user does not want to
    return unless @current_user.email_notify_on_new_inbox_immediately?

    @question = inbox.question
    return unless @question

    # avoid sending a mail for generated questions
    #
    # as of 2022-02-21 there are two possible values for author_name:
    #                "justask" => "get new question" button
    #   "retrospring_exporter" => notification question that's created after an export request
    #
    # always send the mail for the exporter task (TODO: this should be its own notification email),
    # always ignore those from generated questions.
    return if @question.author_name == "justask"

    @asker_name = LocalHelpers.user_screen_name(@question.user, anonymous: @question.author_is_anonymous, url: false)

    mail(
      to: @current_user.email,
      subject: "#{@asker_name} asked you a question on #{APP_CONFIG['site_name']}"
    )
  end

  # @param user [User]
  # @param since_id [Integer] only consider inbox entries starting with this id
  def new_question_in_inbox_batched(user, since_id)
    @current_user = user
    # avoid sending mails if the user does not want to
    return if @current_user.email_notify_on_new_inbox_never?

    # find all new inbox entries since `since_id`
    @inbox_entries = @current_user.inboxes.where(id: since_id.., new: true).order(:id).reverse

    @inbox_count = @inbox_entries.count
    return if @inbox_count.zero? # nothing new here!

    # get the most recent question to show in the mail
    @question = @inbox_entries.first.question
    # @question is unlikely to be from "justask" as generated questions should™ have their inbox
    # entry set to `new=false` immediately after creation

    @asker_name = LocalHelpers.user_screen_name(@question.user, anonymous: @question.author_is_anonymous, url: false)

    mail(
      to: @current_user.email,
      subject: "There are #{@inbox_count} new questions waiting for you on #{APP_CONFIG['site_name']}"
    )
  end
end
