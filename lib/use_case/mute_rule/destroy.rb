# frozen_string_literal: true

module UseCase
  module MuteRule
    class Destroy < UseCase::Base
      option :rule, Types.Instance(::MuteRule)

      def call
        rule.destroy!

        {
          status:   204,
          resource: nil
        }
      end
    end
  end
end
