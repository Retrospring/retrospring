# frozen_string_literal: true

module UseCase
  module Answer
    class Pin < UseCase::Base
      option :user, type: Types.Instance(::User)
      option :answer, type: Types.Instance(::Answer)

      def call
        check_ownership!

        answer.pinned_at = Time.now.utc
        answer.save!

        {
          status:   200,
          resource: answer,
        }
      end

      private

      def check_ownership!
        raise ::Errors::NotAuthorized unless answer.user == user
      end
    end
  end
end
