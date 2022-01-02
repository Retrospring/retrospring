# frozen_string_literal: true

require "use_case/base"
require "errors"

module UseCase
  module Relationship
    class Create < UseCase::Base
      option :current_user_id, type: Types::Coercible::Integer
      option :target_user, type: Types::Coercible::String
      option :type, type: Types::Coercible::String

      def call
        not_blank! :current_user_id, :target_user, :type

        type = @type.downcase
        ensure_type(type)
        source_user = find_source_user
        target_user = find_target_user

        source_user.public_send(type, target_user)

        {
          status: 201,
          resource: true,
          extra: {
            target_user: target_user
          }
        }
      end

      private

      def ensure_type(type)
        raise Errors::BadRequest unless type == 'follow'
      end

      def find_source_user
        user_id = @current_user_id
        User.find(user_id)
      rescue ActiveRecord::RecordNotFound
        raise Errors::UserNotFound
      end

      def find_target_user
        target_user = @target_user
        return target_user if target_user.is_a?(User)
        User.find_by!(screen_name: target_user)
      rescue ActiveRecord::RecordNotFound
        raise Errors::UserNotFound
      end
    end
  end
end
