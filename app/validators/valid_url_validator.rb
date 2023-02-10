# frozen_string_literal: true

class ValidUrlValidator < ActiveModel::EachValidator
  URI_REGEXP = URI::DEFAULT_PARSER.make_regexp(%w[http https]).freeze

  def validate_each(record, attribute, value)
    return if valid?(value)

    record.errors.add(attribute, :invalid_url)
  end

  def valid?(value)
    return false unless URI_REGEXP.match?(value)

    URI.parse(value) # raises URI::InvalidURIError

    true
  rescue URI::InvalidURIError
    false
  end
end
