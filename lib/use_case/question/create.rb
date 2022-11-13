# frozen_string_literal: true

require "use_case/base"
require "errors"

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
        check_user
        check_lock
        check_anonymous_rules
        check_blocks

        question = ::Question.create!(
          content:             content,
          author_is_anonymous: anonymous,
          author_identifier:   author_identifier,
          user:                source_user_id.nil? ? nil : source_user,
          direct:              direct
        )

        return if filtered?(question)

        increment_asked_count

        inbox = ::Inbox.create!(user: target_user, question: question, new: true)

        {
          status:   201,
          resource: question,
          extra:    {
            inbox:
          }
        }
      end

      private

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

      def filtered?(question)
        target_user.mute_rules.any? { |rule| rule.applies_to? question } ||
          (anonymous && AnonymousBlock.where(identifier: question.author_identifier, user_id: [target_user.id, nil]).any?)
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
