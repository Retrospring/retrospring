# frozen_string_literal: true

require "use_case/base"
require "errors"

module UseCase
  module Relationship
    class Create < UseCase::Base
      option :source_user, type: Types.Instance(::User) | Types::Coercible::String
      option :target_user, type: Types.Instance(::User) | Types::Coercible::String
      option :type, type: Types::RelationshipTypes

      def call
        source_user = find_source_user
        target_user = find_target_user

        source_user.public_send(type, target_user)

        {
          status:   201,
          resource: true,
          extra:    {
            target_user: target_user
          }
        }
      end

      private

      def find_source_user
        return source_user if source_user.is_a?(::User)

        ::User.find_by!(screen_name: source_user)
      rescue ActiveRecord::RecordNotFound
        raise Errors::UserNotFound
      end

      def find_target_user
        return target_user if target_user.is_a?(::User)

        ::User.find_by!(screen_name: target_user)
      rescue ActiveRecord::RecordNotFound
        raise Errors::UserNotFound
      end
    end
  end
end
