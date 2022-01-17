# frozen_string_literal: true

class TypoedEmailValidator < ActiveModel::EachValidator
  # this array contains "forbidden" email address endings
  INVALID_ENDINGS = [
    # without @:
    ".con",
    ".coom",

    # with @:
    *%w[
      fmail.com
      gemail.com
      gmail.co
      gmaile.com
      gmaill.com
      icluod.com
      proton.mail
    ].map { "@#{_1}" }
  ].freeze

  def validate_each(record, attribute, value)
    return if valid?(value)

    record.errors[attribute] << "contains a typo"
  end

  private

  def valid?(value)
    # needs an @
    return false unless value.include?("@")

    # part after the @ needs to have at least one period
    return false if value.split("@", 2).last.count(".").zero?

    # finally, common typos
    return false if INVALID_ENDINGS.any? { value.end_with?(_1) }

    true
  end
end
