# frozen_string_literal: true

module UseCase
  module Answer
    class Unpin < UseCase::Base
      option :user, type: Types.Instance(::User)
      option :answer, type: Types.Instance(::Answer)

      def call
        check_ownership!
        check_pinned!

        answer.pinned_at = nil
        answer.save!

        {
          status:   200,
          resource: nil
        }
      end

      private

      def check_ownership!
        raise ::Errors::NotAuthorized unless answer.user == user
      end

      def check_pinned!
        raise ::Errors::BadRequest if answer.pinned_at.nil?
      end
    end
  end
end
