# frozen_string_literal: true

class ScreenNameValidator < ActiveModel::EachValidator
  FORBIDDEN_SCREEN_NAMES = %w[justask_admin retrospring_admin admin justask retrospring about public
                              notifications inbox sign_in sign_up sidekiq moderation moderator mod administrator
                              siteadmin site_admin help retro_spring retroospring retrosprlng niisding nllsding
                              pixeidesu plxeldesu plxeidesu terms privacy linkfilter feedback].freeze
  FORBIDDEN_SCREEN_NAME_REGEXPS = [/wreciap\z/i].freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, message: "Thou shalt not use this username!  Please choose another one.") if FORBIDDEN_SCREEN_NAMES.include?(value.downcase)
    record.errors.add(attribute, message: "Registration is tempoarily disabled for new users.") if FORBIDDEN_SCREEN_NAME_REGEXPS.any? { |regexp| value.downcase =~ regexp }
  end
end
