# frozen_string_literal: true

require "use_case/base"

module UseCase
  module Inbox
    class Answer < UseCase::Base
      option :current_user_id, type: Types::Coercible::Integer
      option :inbox_entry_id, type: Types::Coercible::Integer
      option :content, type: Types::Coercible::String
      option :share_to_services, type: Types::Array.of(Types::Coercible::String)

      def call
        authorize!

        answer = ::Answer.create!(
          content: content,
          user: current_user,
          question: inbox_entry.question
        )
        inbox_entry.destroy

        share_to_services_async(answer)

        {
          answer: answer
        }
      end

      private

      def authorize!
        raise Errors::Forbidden.new("not in current_user's inbox") unless current_user == inbox_entry.user
      end

      def share_to_services_async(answer)
        return if share_to_services.empty?

        ShareWorker.perform_async(current_user_id, answer.id, share_to_services)
      end

      def current_user
        @current_user ||= ::User.find(current_user_id)
      end

      def inbox_entry
        @inbox_entry ||= ::Inbox.find(inbox_entry_id)
      end
    end
  end
end
