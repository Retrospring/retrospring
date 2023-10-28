# frozen_string_literal: true

module UseCase
  module Reaction
    class Destroy < UseCase::Base
      option :source_user, type: Types.Instance(::User)
      option :target, type: Types.Instance(::Answer) | Types.Instance(::Comment)

      def call
        source_user.unsmile target

        {
          status:   204,
          resource: nil,
        }
      end
    end
  end
end
