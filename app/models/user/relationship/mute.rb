# frozen_string_literal: true

class User
  module Relationship
    module Mute
      extend ActiveSupport::Concern

      included do
        has_many :active_mute_relationships, class_name:  "Relationships::Mute",
                                             foreign_key: "source_id",
                                             dependent:   :destroy
        has_many :passive_mute_relationships, class_name:  "Relationships::Mute",
                                              foreign_key: "target_id",
                                              dependent:   :destroy
        has_many :muted_users, through: :active_mute_relationships, source: :target
        has_many :muted_by_users, through: :passive_mute_relationships, source: :source
      end

      # Mute a user
      def mute(target_user)
        raise Errors::MutingSelf if target_user == self

        create_relationship(active_mute_relationships, target_user).tap do
          expire_muted_user_ids_cache
        end
      end

      # Unmute an user
      def unmute(target_user)
        destroy_relationship(active_mute_relationships, target_user).tap do
          expire_muted_user_ids_cache
        end
      end

      # Is <tt>self</tt> muting <tt>target_user</tt>?
      def muting?(target_user)
        relationship_active?(muted_users, target_user)
      end

      # Expires the muted user ids cache
      def expire_muted_user_ids_cache = Rails.cache.delete(cache_key_muted_user_ids)

      # Cached ids of the muted users
      def muted_user_ids_cached
        Rails.cache.fetch(cache_key_muted_user_ids, expires_in: 1.hour) do
          muted_user_ids
        end
      end

      private

      # Cache key for the muted_user_ids
      def cache_key_muted_user_ids = "#{cache_key}/muted_user_ids"
    end
  end
end
