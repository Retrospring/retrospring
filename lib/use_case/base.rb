# frozen_string_literal: true

require 'dry-initializer'
require 'types'
require 'errors'

module UseCase
  class Base
    extend Dry::Initializer

    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    def call
      raise NotImplementedError
    end

    private

    def not_blank!(*args)
      args.each do |arg|
        raise Errors::ParamIsMissing if instance_variable_get("@#{arg}").blank?
      end
    end
  end
end