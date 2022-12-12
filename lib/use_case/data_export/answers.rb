# frozen_string_literal: true

require "use_case/data_export/base"

module UseCase
  module DataExport
    class Answers < UseCase::DataExport::Base
      def files = {
        "answers.json" => json_file!(
          answers: user.answers.map(&method(:collect_answer))
        )
      }

      def collect_answer(answer)
        {}.tap do |h|
          column_names(::Answer).each do |field|
            h[field] = answer[field]
          end
        end
      end
    end
  end
end
