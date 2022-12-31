# frozen_string_literal: true

module UseCase
  module DataExport
    class Relationships < UseCase::DataExport::Base
      def files = {
        "relationships.json" => json_file!(
          relationships: [
            # don't want to add the passive (block) relationships here as it
            # would reveal who e.g. blocked the exported user, which is
            # considered A Bad Idea™
            *user.active_follow_relationships.map(&method(:collect_relationship)),
            *user.active_block_relationships.map(&method(:collect_relationship)),
            *user.active_mute_relationships.map(&method(:collect_relationship))
          ]
        )
      }

      def collect_relationship(relationship)
        {}.tap do |h|
          column_names(::Relationship).each do |field|
            h[field] = relationship[field]
          end
        end
      end
    end
  end
end
