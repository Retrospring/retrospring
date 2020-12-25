# frozen_string_literal: true

require "use_case/base"

module UseCase
  module Question
    class Answer < UseCase::Base
      option :current_user_id, type: Types::Coercible::Integer
      option :question_id, type: Types::Coercible::Integer
      option :content, type: Types::Coercible::String
      option :share_to_services, type: Types::Array.of(Types::Coercible::String)

      def call
        authorize!

        answer = ::Answer.create!(
          content: content,
          user: current_user,
          question: question
        )

        # TODO: perhaps remove this question from the current users' inbox
        # if it is in there?

        share_to_services_async(answer)

        {
          answer: answer
        }
      end

      private

      def authorize!
        raise Errors::Forbidden.new("user does not want strangers to answer their question") unless question.user.privacy_allow_stranger_answers
      end

      def share_to_services_async(answer)
        return if share_to_services.empty?

        ShareWorker.perform_async(current_user_id, answer.id, share_to_services)
      end

      def current_user
        @current_user ||= ::User.find(current_user_id)
      end

      def question
        @question ||= ::Question.find(question_id)
      end
    end
  end
end
