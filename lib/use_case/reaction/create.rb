# frozen_string_literal: true

module UseCase
  module Reaction
    class Create < UseCase::Base
      option :source_user_id, type: Types::Coercible::Integer
      option :target, type: Types.Instance(::Answer) | Types.Instance(::Comment)
      option :content, type: Types::Coercible::String, optional: true

      def call
        reaction = source_user.smile target

        {
          status:   201,
          resource: reaction,
        }
      end

      private

      def source_user
        @source_user ||= ::User.find(source_user_id)
      end
    end
  end
end
