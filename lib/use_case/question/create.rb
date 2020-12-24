# frozen_string_literal: true

require "use_case/base"

module UseCase
  module Question
    class Create < UseCase::Base
      option :source_user_id, type: Types::Coercible::Integer | Types::Nil, optional: true
      option :target_user_id, type: Types::Coercible::Integer
      option :content, type: Types::Coercible::String
      option :anonymous, type: Types::Params::Bool, default: proc { false }

      def call
        check_anonymous_rules

        question = ::Question.create!(
          content: content,
          author_is_anonymous: anonymous,
          user: source_user_id.nil? ? nil : source_user
        )

        increment_asked_count

        inbox = ::Inbox.create!(
          user: target_user, question: question, new: true
        )

        {
          question: question,
          inbox: inbox
        }
      end

      private

      def check_anonymous_rules
        if !source_user_id && !anonymous
          # We can not create a non-anonymous question without a source user
          raise Errors::BadRequest.new("anonymous must be set to true")
        end

        if !target_user.privacy_allow_anonymous_questions && anonymous
          # The target user does not want questions from strangers
          raise Errors::Forbidden.new("no anonymous questions allowed")
        end
      end

      def increment_asked_count
        if !(source_user_id && !anonymous)
          # Only increment the asked count of the source user if the question
          # is not anonymous, and we actually have a source user
          return
        end

        source_user.increment!(:asked_count)
      end

      def source_user
        @source_user ||= User.find(source_user_id)
      end

      def target_user
        @target_user ||= User.find(target_user_id)
      end
    end
  end
end
