# frozen_string_literal: true

require 'use_case/base'

module UseCase
  module User
    class Unban < UseCase::Base
      param :target_user_id, type: Types::Coercible::Integer

      def call
        UserBan.current.where(user_id: target_user_id).update_all(
          # -1s to account for flakyness with timings in tests
          expires_at: DateTime.now - 1.second
        )
      end
    end
  end
end