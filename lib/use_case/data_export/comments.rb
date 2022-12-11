# frozen_string_literal: true

require "use_case/data_export/base"

module UseCase
  module DataExport
    class Comments < UseCase::DataExport::Base
      def files = {
        "comments.json" => json_file!(
          comments: user.comments.map(&method(:collect_comment))
        )
      }

      def collect_comment(comment)
        {}.tap do |h|
          column_names(::Comment).each do |field|
            h[field] = comment[field]
          end
        end
      end
    end
  end
end
