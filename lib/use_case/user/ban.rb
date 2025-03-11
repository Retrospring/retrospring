# frozen_string_literal: true

module UseCase
  module User
    class Ban < UseCase::Base
      REASON_SPAM = "Spam"
      REASON_HARASSMENT = "Harassment"
      REASON_BAN_EVASION = "Ban evasion"

      option :target_user_id, type: Types::Coercible::Integer
      option :expiry, types: Types::Nominal::DateTime.optional
      option :source_user_id, type: Types::Coercible::Integer.optional
      option :reason, type: Types::Coercible::String.optional

      def call
        ban = target_user.ban(expiry, reason, source_user)

        if reason == REASON_SPAM
          target_user.update!(
            profile_picture: nil,
            profile_header:  nil,
          )
          target_user.profile.update!(
            display_name: nil,
            description:  "",
            location:     "",
            website:      "",
          )
        end

        if permanent_ban?
          remove_inbox_entries
          resolve_reports
        end

        {
          status:   201,
          resource: ban,
          extra:    {
            target_user:,
          },
        }
      end

      def target_user
        @target_user ||= ::User.find(target_user_id)
      end

      def source_user
        @source_user ||= ::User.find(source_user_id) if source_user_id
      end

      private

      def permanent_ban?
        expiry.nil?
      end

      def remove_inbox_entries
        ::InboxEntry.joins(:question).where(questions: { user_id: target_user_id }).destroy_all
      end

      def resolve_reports
        ::Report.where(target_user_id: target_user_id).update_all(resolved: true) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
