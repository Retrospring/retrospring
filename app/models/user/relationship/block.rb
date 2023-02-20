# frozen_string_literal: true

class User
  module Relationship
    module Block
      extend ActiveSupport::Concern

      included do
        has_many :active_block_relationships, class_name:  "Relationships::Block",
                                              foreign_key: "source_id",
                                              dependent:   :destroy
        has_many :passive_block_relationships, class_name:  "Relationships::Block",
                                               foreign_key: "target_id",
                                               dependent:   :destroy
        has_many :blocked_users,    through: :active_block_relationships, source: :target
        has_many :blocked_by_users, through: :passive_block_relationships, source: :source
      end

      # Block an user
      def block(target_user)
        raise Errors::BlockingSelf if target_user == self

        unfollow_and_remove(target_user)
        create_relationship(active_block_relationships, target_user).tap do
          expire_blocked_user_ids_cache
        end
      end

      # Unblock an user
      def unblock(target_user)
        destroy_relationship(active_block_relationships, target_user).tap do
          expire_blocked_user_ids_cache
        end
      end

      # Is <tt>self</tt> blocking <tt>target_user</tt>?
      def blocking?(target_user)
        relationship_active?(blocked_users, target_user)
      end

      # Expire the blocked user ids cache
      def expire_blocked_user_ids_cache = Rails.cache.delete(cache_key_blocked_user_ids)

      # Cached ids of the blocked users
      def blocked_user_ids_cached
        Rails.cache.fetch(cache_key_blocked_user_ids, expires_in: 1.hour) do
          blocked_user_ids
        end
      end

      private

      def unfollow_and_remove(target_user)
        unfollow(target_user) if following?(target_user)
        target_user.unfollow(self) if target_user.following?(self)
        target_user.inboxes.joins(:question).where(question: { user_id: id }).destroy_all
        inboxes.joins(:question).where(questions: { user_id: target_user.id, author_is_anonymous: false }).destroy_all
        ListMember.joins(:list).where(list: { user_id: target_user.id }, user_id: id).destroy_all
      end

      def cache_key_blocked_user_ids = "#{cache_key}/blocked_user_ids"
    end
  end
end
