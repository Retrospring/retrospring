# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails"

if ENV.key?("CODECOV_TOKEN")
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
