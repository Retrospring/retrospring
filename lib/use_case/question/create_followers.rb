# frozen_string_literal: true

module UseCase
  module Question
    class CreateFollowers < UseCase::Base
      option :source_user_id, type: Types::Coercible::Integer
      option :content, type: Types::Coercible::String
      option :author_identifier, type: Types::Coercible::String | Types::Nil

      def call
        question = ::Question.create!(
          content:,
          author_is_anonymous: false,
          author_identifier:,
          user:                source_user,
          direct:              false
        )

        increment_asked_count
        increment_metric

        QuestionWorker.perform_async(source_user_id, question.id)

        {
          status:   201,
          resource: question,
        }
      end

      private

      def increment_asked_count
        source_user.increment(:asked_count)
        source_user.save
      end

      def increment_metric
        Retrospring::Metrics::QUESTIONS_ASKED.increment(
          labels: {
            anonymous: false,
            followers: true,
            generated: false,
          }
        )
      end

      def source_user
        @source_user ||= ::User.find(source_user_id)
      end
    end
  end
end
