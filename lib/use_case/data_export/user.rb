# frozen_string_literal: true

require "httparty"

module UseCase
  module DataExport
    class User < UseCase::DataExport::Base
      EXPORT_ROLES = %i[administrator moderator].freeze

      IGNORED_FIELDS_USERS = %i[
        confirmation_token
        encrypted_password
        otp_secret_key
        reset_password_sent_at
        reset_password_token
        inbox_updated_at
        notifications_updated_at
      ].freeze

      IGNORED_FIELDS_PROFILES = %i[
        id
        user_id
      ].freeze

      def files = {
        "user.json" => json_file!(
          user:    user_data,
          profile: profile_data,
          roles:   roles_data
        ),
        **pictures
      }

      def user_data
        {}.tap do |obj|
          (column_names(::User) - IGNORED_FIELDS_USERS).each do |field|
            obj[field] = user[field]
          end
        end
      end

      def profile_data
        {}.tap do |profile|
          (column_names(::Profile) - IGNORED_FIELDS_PROFILES).each do |field|
            profile[field] = user.profile[field]
          end
        end
      end

      def roles_data
        {}.tap do |obj|
          EXPORT_ROLES.each do |role|
            obj[role] = user.has_role?(role)
          end
        end
      end

      def pictures
        {}.tap do |hash|
          add_picture(user.profile_picture, to: hash)
          add_picture(user.profile_header, to: hash)
        end.compact
      end

      def add_picture(picture, to:)
        return if picture.blank?

        picture.versions.each do |version, file|
          export_filename = "pictures/#{file.mounted_as}_#{version}_#{file.filename}"
          to[export_filename] = if file.url.start_with?("/")
                                  Rails.public_path.join(file.url.sub(%r{\A/+}, "")).read
                                else
                                  HTTParty.get(file.url).parsed_response
                                end
        end
      end
    end
  end
end
