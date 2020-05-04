# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails"

if ENV.key?("GITHUB_ACTIONS")
  require "simplecov-cobertura"
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end
