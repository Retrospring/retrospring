# frozen_string_literal: true

class CreateInitialRoles < ActiveRecord::Migration[5.2]
  def up
    %w[Administrator Moderator].each do |role|
      Role.where(name: role.parameterize).first_or_create
    end

    {
      admin:     :administrator,
      moderator: :moderator,
    }.each do |legacy_role, new_role|
      User.where(legacy_role => true).find_each do |u|
        Rails.logger.debug { "-- migrating #{u.screen_name} (#{u.id}) from field:#{legacy_role} to role:#{new_role}" }
        u.add_role new_role
        u.public_send("#{legacy_role}=", false)
        u.save!
      end
    end
  end

  def down
    {
      administrator: :admin,
      moderator:     :moderator,
    }.each do |new_role, legacy_role|
      User.with_role(new_role).each do |u|
        Rails.logger.debug { "-- migrating #{u.screen_name} (#{u.id}) from role:#{new_role} to field:#{legacy_role}" }
        u.public_send("#{legacy_role}=", true)
        u.save!
      end
    end
  end
end
