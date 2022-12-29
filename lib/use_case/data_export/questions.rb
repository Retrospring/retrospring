# frozen_string_literal: true

module UseCase
  module DataExport
    class Questions < UseCase::DataExport::Base
      IGNORED_FIELDS = %i[
        author_identifier
      ].freeze

      def files = {
        "questions.json" => json_file!(
          questions: user.questions.map(&method(:collect_question))
        )
      }

      def collect_question(question)
        {}.tap do |h|
          (column_names(::Question) - IGNORED_FIELDS).each do |field|
            h[field] = question[field]
          end
        end
      end
    end
  end
end
