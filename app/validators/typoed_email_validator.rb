# frozen_string_literal: true

require "tldv"

class TypoedEmailValidator < ActiveModel::EachValidator
  # this array contains "forbidden" email address endings
  INVALID_ENDINGS = [
    # with @:
    *%w[
      aoo.com
      fmail.com
      gail.com
      gamil.com
      gemail.com
      gmaik.com
      gmail.cm
      gmail.co
      gmail.co.uk
      gmail.om
      gmaile.com
      gmaill.com
      gmali.com
      gmaul.com
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
    _prefix, domain = value.split("@", 2)
    domain_parts = domain.split(".")
    return false if domain_parts.length == 1

    # check if the TLD is valid
    tld = domain_parts.last
    return false unless TLDv.valid?(tld)

    # finally, common typos
    return false if INVALID_ENDINGS.any? { value.end_with?(_1) }

    true
  end
end
