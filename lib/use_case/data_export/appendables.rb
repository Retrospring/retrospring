# frozen_string_literal: true

module UseCase
  module DataExport
    class Appendables < UseCase::DataExport::Base
      def files = {
        "appendables.json" => json_file!(
          appendables: [
            *user.smiles.map(&method(:collect_appendable))
          ]
        )
      }

      def collect_appendable(appendable)
        {}.tap do |h|
          column_names(::Appendable).each do |field|
            h[field] = appendable[field]
          end
        end
      end
    end
  end
end
