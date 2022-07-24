# frozen_string_literal: true

require "use_case/base"
require "errors"

module UseCase
  module MuteRule
    class Destroy < UseCase::Base
      option :user, type: Types.Instance(::User)
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
