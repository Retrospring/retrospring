# frozen_string_literal: true

class User
  module Relationship
    extend ActiveSupport::Concern

    private

    # Create a relationship for `type` with `target_user` as target.
    def create_relationship(type, target_user)
      type.create(target: target_user)
    end

    # Destroy a relationship for `type` with `target_user` as target.
    def destroy_relationship(type, target_user)
      type.find_by(target: target_user)&.destroy
    end

    def relationship_active?(type, target_user)
      type.include?(target_user)
    end
  end
end
