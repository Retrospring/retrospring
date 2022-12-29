# frozen_string_literal: true

require "json"

module UseCase
  module DataExport
    class Base < UseCase::Base
      # the user that is being exported
      option :user

      def call = files

      # returns a hash with `{ "file_name" => "file_contents\n" }`
      def files = raise NotImplementedError

      # helper method that returns the column names of `model` as symbols
      def column_names(model) = model.column_names.map(&:to_sym)

      # helper method that generates the content of a json file
      #
      # it ensures the final newline exists, as the exporter only uses File#write
      def json_file!(**hash) = "#{JSON.pretty_generate(hash.as_json)}\n"
    end
  end
end
