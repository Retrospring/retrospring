# frozen_string_literal: true

class TypoedEmailValidator < ActiveModel::EachValidator
  # this array contains "forbidden" email address endings
  INVALID_ENDINGS = [
    # without @:
    ".carrd",
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
      gmaik.com
      gmail.cm
      gmail.co
      gmail.co.uk
      gmaile.com
      gmaill.com
      gmali.com
      gnail.com
      hotamil.com
      hotmai.com
      hotmaill.com
      iclooud.com
      iclould.com
      icluod.com
      protonail.com
      xn--gmail-xk1c.com
      yahooo.com
      ☺gmail.com
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
