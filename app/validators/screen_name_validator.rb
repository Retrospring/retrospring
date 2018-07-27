class ScreenNameValidator < ActiveModel::EachValidator
  FORBIDDEN_SCREEN_NAMES = %w(justask_admin retrospring_admin admin justask retrospring about public
                              notifications inbox sign_in sign_up sidekiq moderation moderator mod administrator
                              siteadmin site_admin help retro_spring retroospring retrosprlng niisding nllsding 
                              pixeidesu plxeldesu plxeidesu terms privacy)
  FORBIDDEN_SCREEN_NAME_REGEXPS = [/wreciap\z/i]

  def validate_each(record, attribute, value)
    if FORBIDDEN_SCREEN_NAMES.include? value.downcase
      record.errors[attribute] << "Thou shalt not use this username!  Please choose another one."
    end
    if FORBIDDEN_SCREEN_NAME_REGEXPS.any? { |regexp| value.downcase =~ regexp }
      record.errors[attribute] << "Registration is tempoarily disabled for new users."
    end
  end
end
