# frozen_string_literal: true

require "use_case/base"
require "errors"

module UseCase
  module Relationship
    class Create < UseCase::Base
      option :source_user, type: Types.Instance(::User)
      option :target_user, type: Types.Instance(::User)
      option :type, type: Types::RelationshipTypes

      def call
        source_user.public_send(type, target_user)

        {
          status:   201,
          resource: true,
          extra:    {
            target_user: target_user
          }
        }
      end
    end
  end
end
