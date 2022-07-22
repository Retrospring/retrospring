# frozen_string_literal: true

class ScreenNameValidator < ActiveModel::EachValidator
  FORBIDDEN_SCREEN_NAMES = APP_CONFIG["forbidden_screen_names"].freeze
  FORBIDDEN_SCREEN_NAME_REGEXPS = [/wreciap\z/i].freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, message: "Thou shalt not use this username!  Please choose another one.") if FORBIDDEN_SCREEN_NAMES.include?(value.downcase)
    record.errors.add(attribute, message: "Registration is tempoarily disabled for new users.") if FORBIDDEN_SCREEN_NAME_REGEXPS.any? { |regexp| value.downcase =~ regexp }
  end
end
