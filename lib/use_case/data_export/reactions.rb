# frozen_string_literal: true

module UseCase
  module DataExport
    class Reactions < UseCase::DataExport::Base
      def files = {
        "reactions.json" => json_file!(
          reactions: [
            *user.smiles.map(&method(:collect_reaction))
          ],
        ),
      }

      def collect_reaction(reaction)
        {}.tap do |h|
          column_names(::Reaction).each do |field|
            h[field] = reaction[field]
          end
        end
      end
    end
  end
end
