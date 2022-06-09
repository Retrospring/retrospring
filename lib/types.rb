# frozen_string_literal: true

require "dry-types"

module Types
  include Dry.Types()

  RelationshipTypes = Types::String.enum("follow", "block")
end
