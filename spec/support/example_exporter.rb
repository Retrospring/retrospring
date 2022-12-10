# frozen_string_literal: true

raise ArgumentError.new("This file should only be required in the 'test' environment!  Current environment: #{Rails.env}") unless Rails.env.test?

require "use_case/data_export/base"

# an example exporter to be used for the tests of `Exporter`
#
# this only returning basic files, nothing user-specific.  each exporter should be tested individually.
class ExampleExporter < UseCase::DataExport::Base
  def files = {
    "textfile.txt"         => "Sample Text\n",
    "pictures/example.jpg" => File.read(File.expand_path("../fixtures/files/banana_racc.jpg", __dir__)),
    "some.json"            => json_file!(
      animals:    %w[raccoon fox hyena deer dog],
      big_number: 3457812374589235798,
      booleans:   {
        yes:            true,
        no:             false,
        file_not_found: nil
      }
    )
  }
end
