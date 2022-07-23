# frozen_string_literal: true

require 'use_case/base'

module UseCase
  module User
    class Unban < UseCase::Base
      param :target_user_id, type: Types::Coercible::Integer

      def call
        target_user.unban

        {
          status:   204,
          resource: nil,
          extra:    {
            target_user: target_user
          }
        }
      end

      def target_user
        @target_user ||= ::User.find(target_user_id)
      end
    end
  end
end