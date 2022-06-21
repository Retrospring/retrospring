# frozen_string_literal: true

class TypoedEmailValidator < ActiveModel::EachValidator
  # this array contains "forbidden" email address endings
  INVALID_ENDINGS = [
    # without @:
    ".con",
    ".coom",
    ".cmo",
    ".mail",

    # with @:
    *%w[
      fmail.com
      gail.com
      gamil.com
      gemail.com
      gmail.cm
      gmail.co
      gmaile.com
      gmaill.com
      gmali.com
      hotamil.com
      hotmaill.com
      iclooud.com
      iclould.com
      icluod.com
    ].map { "@#{_1}" }
  ].freeze

  def validate_each(record, attribute, value)
    return if valid?(value)

    record.errors.add(attribute, :typo, message: "contains a typo")
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
