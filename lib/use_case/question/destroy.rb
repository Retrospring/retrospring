# frozen_string_literal: true

require "use_case/base"

module UseCase
  module Question
    class Destroy < UseCase::Base
      option :current_user_id, type: Types::Coercible::Integer
      option :question_id, type: Types::Coercible::Integer

      def call
        authorize!

        question.destroy!

        {
          question: question
        }
      end

      private

      def authorize!
        raise Errors::NotAuthorized unless allowed?
      end

      def allowed?
        current_user.mod? || (current_user == question.user)
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
