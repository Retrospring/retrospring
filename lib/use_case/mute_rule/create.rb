# frozen_string_literal: true

module UseCase
  module MuteRule
    class Create < UseCase::Base
      option :user, type: Types.Instance(::User)
      option :phrase, type: Types::Coercible::String

      def call
        rule = ::MuteRule.create!(
          user:,
          muted_phrase: phrase
        )

        {
          status:   201,
          resource: rule
        }
      end
    end
  end
end
