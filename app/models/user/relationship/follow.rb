# frozen_string_literal: true

require "errors"

class User
  module Relationship
    module Follow
      extend ActiveSupport::Concern

      included do
        has_many :active_follow_relationships, class_name:  "Relationships::Follow",
                                               foreign_key: "source_id",
                                               dependent:   :destroy
        has_many :passive_follow_relationships, class_name:  "Relationships::Follow",
                                                foreign_key: "target_id",
                                                dependent:   :destroy
        has_many :followings, through: :active_follow_relationships, source: :target
        has_many :followers,  through: :passive_follow_relationships, source: :source
      end

      # Follow an user
      def follow(target_user)
        raise Errors::FollowingSelf if target_user == self
        raise Errors::FollowingOtherBlockedSelf if target_user.blocked_by?(self)
        raise Errors::FollowingSelfBlockedOther if blocked_by?(target_user)

        create_relationship(active_follow_relationships, target_user)
      end

      # Unfollow an user
      def unfollow(target_user)
        destroy_relationship(active_follow_relationships, target_user)
      end

      def following?(target_user)
        relationship_active?(followings, target_user)
      end
    end
  end
end
