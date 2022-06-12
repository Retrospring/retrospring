# frozen_string_literal: true

require "errors"

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
        create_relationship(active_block_relationships, target_user)
      end

      # Unblock an user
      def unblock(target_user)
        destroy_relationship(active_block_relationships, target_user)
      end

      # Is <tt>self</tt> blocking <tt>target_user</tt>?
      def blocking?(target_user)
        relationship_active?(blocked_users, target_user)
      end

      private

      def unfollow_and_remove(target_user)
        unfollow(target_user) if following?(target_user)
        target_user.unfollow(self) if target_user.following?(self)
        target_user.inboxes.joins(:question).where(question: { user_id: id }).destroy_all
        inboxes.joins(:question).where(questions: { user_id: target_user.id, author_is_anonymous: false }).destroy_all
        ListMember.joins(:list).where(list: { user_id: target_user.id }, user_id: id).destroy_all
      end
    end
  end
end
