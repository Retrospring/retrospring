# frozen_string_literal: true

require 'use_case/base'

module UseCase
  module User
    class Ban < UseCase::Base
      REASON_SPAM = 'Spam'
      REASON_HARASSMENT = 'Harassment'
      REASON_BAN_EVASION = 'Ban evasion'

      option :target_user_id, type: Types::Coercible::Integer
      option :expiry, types: Types::Nominal::DateTime.optional
      option :source_user_id, type: Types::Coercible::Integer.optional
      option :reason, type: Types::Coercible::String.optional

      def call
        ban = ::UserBan.create!(
          user: target_user,
          expires_at: expiry,
          banned_by: source_user,
          reason: reason
        )

        if reason == REASON_SPAM
          target_user.update!(
            display_name: nil,
            bio: '',
            location: '',
            website: '',
            profile_picture: nil,
            profile_header: nil
          )
        end

        {
          ban: ban
        }
      end

      def target_user
        @target_user ||= ::User.find(target_user_id)
      end

      def source_user
        @source_user ||= ::User.find(source_user_id)
      end
    end
  end
end
