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

      def mute(target_user)
        raise Errors::MutingSelf if target_user == self

        create_relationship(active_mute_relationships, target_user)
      end

      def unmute(target_user)
        destroy_relationship(active_mute_relationships, target_user)
      end

      def muting?(target_user)
        relationship_active?(muted_users, target_user)
      end
    end
  end
end
