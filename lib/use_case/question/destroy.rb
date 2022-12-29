# frozen_string_literal: true

module UseCase
  module Question
    class Destroy < UseCase::Base
      option :question_id, type: Types::Coercible::Integer
      option :current_user, type: Types::Instance(::User)

      def call
        question = ::Question.find(question_id)

        raise Errors::Forbidden unless current_user&.mod? || question.user == current_user

        question.destroy!

        {
          status:   204,
          resource: nil,
        }
      end
    end
  end
end
