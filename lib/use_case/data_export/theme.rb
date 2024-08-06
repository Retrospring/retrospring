# frozen_string_literal: true

module UseCase
  module DataExport
    class Theme < UseCase::DataExport::Base
      include ThemeHelper

      MODEL_FIELDS = %i[id user_id created_at updated_at].freeze

      def files
        return {} unless user.theme

        {
          "theme.json" => json_file!(
            theme: theme_data,
          ),
        }
      end

      def theme_data
        {}.tap do |obj|
          (column_names(::Theme) - MODEL_FIELDS).each do |field|
            obj[field] = "##{get_hex_color_from_theme_value(user.theme[field])}"
          end
        end
      end
    end
  end
end
