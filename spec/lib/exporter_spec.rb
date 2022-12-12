# frozen_string_literal: true

require "rails_helper"
require "support/example_exporter"
require "base64"

require "exporter"

# This only tests the exporter itself to make sure zip file creation works.
RSpec.describe Exporter do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user, screen_name: "fizzyraccoon", export_processing: true) }
  let(:instance) { described_class.new(user) }
  let(:zipfile_deletion_expected) { false }

  before do
    stub_const("APP_CONFIG", {
      "site_name"      => "justask",
      "hostname"       => "example.com",
      "https"          => true,
      "items_per_page" => 5,
      "fog"            => {}
    }.with_indifferent_access)
  end

  after do
    filename = instance.instance_variable_get(:@zipfile)&.name
    unless File.exist?(filename)
      warn "exporter_spec.rb: wanted to clean up #{filename.inspect} but it does not exist!" unless zipfile_deletion_expected
      next
    end
    FileUtils.rm_r(filename)
  end

  describe "#export" do
    let(:export_name) { instance.instance_variable_get(:@export_name) }

    subject do
      travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) do
        instance.export
      end
    end

    before do
      allow(UseCase::DataExport::Base)
        .to receive(:descendants)
        .and_return([ExampleExporter])
    end

    it "creates a zip file with the expected contents" do
      subject

      # check created zip file
      zip_path = Rails.public_path.join("export/#{export_name}.zip")
      expect(File.exist?(zip_path)).to be true

      Zip::File.open(zip_path) do |zip|
        # check for zip comment
        expect(zip.comment).to eq "justask export done for fizzyraccoon on 2022-12-10T13:37:42Z\n"

        # check if all files and directories are there
        expect(zip.entries.map(&:name).sort).to eq([
          # basic dirs from exporter
          "#{export_name}/",
          "#{export_name}/pictures/",
          # files added by the ExampleExporter
          "#{export_name}/textfile.txt",
          "#{export_name}/pictures/example.jpg",
          "#{export_name}/some.json"
        ].sort)

        # check if the file contents match
        expect(zip.file.read("#{export_name}/textfile.txt")).to eq("Sample Text\n")
        expect(Base64.encode64(zip.file.read("#{export_name}/pictures/example.jpg")))
          .to eq(Base64.encode64(File.read(File.expand_path("../fixtures/files/banana_racc.jpg", __dir__))))
        expect(zip.file.read("#{export_name}/some.json")).to eq(<<~JSON)
          {
            "animals": [
              "raccoon",
              "fox",
              "hyena",
              "deer",
              "dog"
            ],
            "big_number": 3457812374589235798,
            "booleans": {
              "yes": true,
              "no": false,
              "file_not_found": null
            }
          }
        JSON
      end
    end

    it "updates the export fields of the user" do
      expect { subject }.to change { user.export_processing }.from(true).to(false)
      expect(user.export_url).to eq("https://example.com/export/#{export_name}.zip")
      expect(user.export_created_at).to eq(Time.utc(2022, 12, 10, 13, 37, 42))
      expect(user).to be_persisted
    end

    context "when exporting fails" do
      let(:zipfile_deletion_expected) { true }

      before do
        allow_any_instance_of(ExampleExporter).to receive(:files).and_raise(ArgumentError.new("just testing"))
      end

      it "deletes the zip file" do
        expect { subject }.to raise_error(ArgumentError, "just testing")

        zip_path = Rails.public_path.join("export/#{export_name}.zip")
        expect(File.exist?(zip_path)).to be false
      end
    end
  end
end
