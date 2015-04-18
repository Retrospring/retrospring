class ScreenNameValidator < ActiveModel::EachValidator
  FORBIDDEN_SCREEN_NAMES = %w(justask_admin retrospring_admin admin justask retrospring about public
                              notifications inbox sign_in sign_up sidekiq moderation moderator mod administrator
                              siteadmin site_admin help retro_spring retroospring retrosprlng niisding nllsding 
                              pixeidesu plxeldesu plxeidesu terms privacy)

  def validate_each(record, attribute, value)
    if FORBIDDEN_SCREEN_NAMES.include? value.downcase
      record.errors[attribute] << "Thou shalt not use this username!  Please choose another one."
    end
  end
end
