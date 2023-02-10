# frozen_string_literal: true

module UseCase
  module Answer
    class Pin < UseCase::Base
      option :user, type: Types.Instance(::User)
      option :answer, type: Types.Instance(::Answer)

      def call
        authorize!(:pin, user, answer)
        check_unpinned!

        answer.pinned_at = Time.now.utc
        answer.save!

        {
          status:   200,
          resource: answer,
        }
      end

      private

      def check_unpinned!
        raise ::Errors::BadRequest if answer.pinned_at.present?
      end
    end
  end
end
