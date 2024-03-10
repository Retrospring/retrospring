# frozen_string_literal: true

module UseCase
  module Question
    class Create < UseCase::Base
      option :source_user_id, type: Types::Coercible::Integer | Types::Nil, optional: true
      option :target_user_id, type: Types::Coercible::Integer
      option :content, type: Types::Coercible::String
      option :anonymous, type: Types::Params::Bool, default: proc { false }
      option :author_identifier, type: Types::Coercible::String | Types::Nil
      option :direct, type: Types::Params::Bool, default: proc { true }

      def call
        do_checks!

        question = create_question

        return if filtered?(question)

        increment_asked_count
        increment_metric

        inbox = ::InboxEntry.create!(user: target_user, question:, new: true)
        notify(inbox)

        {
          status:   201,
          resource: question,
          extra:    {
            inbox:,
          },
        }
      end

      private

      def do_checks!
        check_user
        check_lock
        check_anonymous_rules
        check_blocks
      end

      def check_lock
        raise Errors::InboxLocked if target_user.inbox_locked?
      end

      def check_anonymous_rules
        if !source_user_id && !anonymous
          # We can not create a non-anonymous question without a source user
          raise Errors::BadRequest.new("anonymous must be set to true")
        end

        # The target user does not want questions from strangers
        raise Errors::Forbidden.new("no anonymous questions allowed") if !target_user.privacy_allow_anonymous_questions && anonymous
      end

      def check_blocks
        return if source_user_id.blank?

        raise Errors::AskingOtherBlockedSelf if target_user.blocking?(source_user)
        raise Errors::AskingSelfBlockedOther if source_user.blocking?(target_user)
      end

      def check_user
        raise Errors::NotAuthorized if target_user.privacy_require_user && !source_user_id
        raise Errors::QuestionTooLong if content.length > ::Question::SHORT_QUESTION_MAX_LENGTH && !target_user.profile.allow_long_questions
        raise Errors::QuestionTooLong if content.length > ::Question::LONG_QUESTION_MAX_LENGTH && target_user.profile.allow_long_questions
      end

      def create_question
        ::Question.create!(
          content:,
          author_is_anonymous: anonymous,
          author_identifier:,
          user:                source_user_id.nil? ? nil : source_user,
          direct:
        )
      end

      def notify(inbox)
        webpush_app = ::Rpush::App.find_by(name: "webpush")
        target_user.push_notification(webpush_app, inbox) if webpush_app
      end

      def increment_asked_count
        unless source_user_id && !anonymous && !direct
          # Only increment the asked count of the source user if the question
          # is not anonymous, and is not direct, and we actually have a source user
          return
        end

        source_user.increment(:asked_count)
        source_user.save
      end

      def increment_metric
        Retrospring::Metrics::QUESTIONS_ASKED.increment(
          labels: {
            anonymous:,
            followers: false,
            generated: false,
          }
        )
      end

      def filtered?(question)
        target_user.mute_rules.any? { |rule| rule.applies_to? question } ||
          (anonymous && AnonymousBlock.where(identifier: question.author_identifier, user_id: [target_user.id, nil]).any?) ||
          (source_user_id && anonymous && AnonymousBlock.where(target_user_id: source_user.id, user_id: [target_user.id, nil]).any?) ||
          (source_user_id && target_user.muting?(source_user))
      end

      def source_user
        @source_user ||= ::User.find(source_user_id)
      end

      def target_user
        @target_user ||= ::User.find(target_user_id)
      end
    end
  end
end
