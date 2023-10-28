# frozen_string_literal: true

module UseCase
  module Reaction
    class Create < UseCase::Base
      option :source_user, type: Types.Instance(::User)
      option :target, type: Types.Instance(::Answer) | Types.Instance(::Comment)
      option :content, type: Types::Coercible::String, optional: true

      def call
        reaction = source_user.smile target

        {
          status:   201,
          resource: reaction,
        }
      end
    end
  end
end
