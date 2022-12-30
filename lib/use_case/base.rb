# frozen_string_literal: true

require "dry-initializer"

module UseCase
  class Base
    extend Dry::Initializer

    def self.call(...) = new(...).call

    def call = raise NotImplementedError
  end
end
