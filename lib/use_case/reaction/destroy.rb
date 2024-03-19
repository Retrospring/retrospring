# frozen_string_literal: true

module UseCase
  module Reaction
    class Destroy < UseCase::Base
      option :source_user_id, type: Types::Coercible::Integer
      option :target, type: Types.Instance(::Answer) | Types.Instance(::Comment)

      def call
        source_user.unsmile target

        {
          status:   204,
          resource: nil,
        }
      end

      private

      def source_user
        @source_user ||= ::User.find(source_user_id)
      end
    end
  end
end
