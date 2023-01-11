# frozen_string_literal: true

require "rails_helper"
require "support/load_rake_tasks"

describe "version bumping tasks" do
  include ActiveSupport::Testing::TimeHelpers

  describe "version:bump" do
    around do |example|
      # make a backup of our version file
      version_path = Rails.root.join("lib/retrospring/version.rb")
      version_contents = File.read(version_path)
      example.run
    ensure
      # restore our version file
      File.write(version_path, version_contents)
    end

    it "updates the version if the version date differs" do
      travel_to(Time.utc(2069, 6, 21, 13, 37, 0))
      allow($stdout).to receive(:puts)

      Rake::Task["version:bump"].execute

      expect($stdout).to have_received(:puts).with "New version: 2069.0621.0"
      travel_back
    end

    context "when version is already from today" do
      before do
        allow(Retrospring::Version).to receive(:year).and_return 2069
        allow(Retrospring::Version).to receive(:month).and_return 6
        allow(Retrospring::Version).to receive(:day).and_return 21
        allow(Retrospring::Version).to receive(:patch).and_return 0

        # just stubbing the constant is not enough, we need to stub away the
        # reading of the version file too; otherwise only the patch value is
        # updated
        version_path = Rails.root.join("lib/retrospring/version.rb")
        version_contents = File.read(version_path)
                               .sub!(/def year = .+/,  "def year = 2069")
                               .sub!(/def month = .+/, "def month = 6")
                               .sub!(/def day = .+/,   "def day = 21")
                               .sub!(/def patch = .+/, "def patch = 0")
        allow(File).to receive(:read).with(version_path).and_return(version_contents)
      end

      it "updates the version if the version date differs" do
        travel_to(Time.utc(2069, 6, 21, 13, 37, 0))
        allow($stdout).to receive(:puts)

        Rake::Task["version:bump"].execute

        expect($stdout).to have_received(:puts).with "Current version: 2069.0621.0"
        expect($stdout).to have_received(:puts).with "New version: 2069.0621.1"
        travel_back
      end
    end
  end

  describe "version:commit" do
    before do
      allow(Retrospring::Version).to receive(:year).and_return 2069
      allow(Retrospring::Version).to receive(:month).and_return 6
      allow(Retrospring::Version).to receive(:day).and_return 21
      allow(Retrospring::Version).to receive(:patch).and_return 3
    end

    it "runs the correct git commands" do
      allow($stdout).to receive(:puts)
      version_path = Rails.root.join("lib/retrospring/version.rb")

      expect_any_instance_of(Rake::FileUtilsExt)
        .to receive(:sh)
        .with(%(git commit -m 'Bump version to 2069.0621.3' -- #{version_path.to_s.inspect}))
      expect_any_instance_of(Rake::FileUtilsExt)
        .to receive(:sh)
        .with(%(git tag -a -m 'Bump version to 2069.0621.3' 2069.0621.3))

      Rake::Task["version:commit"].execute
    end
  end
end
