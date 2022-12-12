# frozen_string_literal: true

require "use_case/data_export/base"

module UseCase
  module DataExport
    class Theme < UseCase::DataExport::Base
      def files
        return {} unless user.theme

        {
          "theme.json" => json_file!(
            theme: theme_data
          )
        }
      end

      def theme_data
        {}.tap do |obj|
          column_names(::Theme).each do |field|
            obj[field] = user.theme[field]
          end
        end
      end
    end
  end
end
