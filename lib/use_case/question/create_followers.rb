# frozen_string_literal: true

require "use_case/base"

module UseCase
  module Question
    class CreateFollowers < UseCase::Base
      option :source_user_id, type: Types::Coercible::Integer
      option :content, type: Types::Coercible::String
      option :author_identifier, type: Types::Coercible::String | Types::Nil

      def call
        question = ::Question.create!(
          content:             content,
          author_is_anonymous: false,
          author_identifier:   author_identifier,
          user:                source_user,
          direct:              false
        )

        increment_asked_count

        QuestionWorker.perform_async(source_user_id, question.id)

        {
          question: question
        }
      end

      private

      def increment_asked_count
        source_user.increment(:asked_count)
      end

      def source_user
        @source_user ||= ::User.find(source_user_id)
      end
    end
  end
end
