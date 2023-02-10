# frozen_string_literal: true

require "dry-initializer"

module UseCase
  class Base
    extend Dry::Initializer

    def self.call(...) = new(...).call

    def call = raise NotImplementedError

    private

    def authorize!(verb, user, record, error_class: Errors::NotAuthorized)
      raise error_class unless Pundit.policy!(user, record).public_send("#{verb}?")
    end
  end
end
