# frozen_string_literal: true

RSpec.describe Retrospring::Version do
  before(:each) do
    allow(Retrospring::Version).to receive(:year) { 1984 }
    allow(Retrospring::Version).to receive(:month) { 1 }
    allow(Retrospring::Version).to receive(:day) { 1 }
    allow(Retrospring::Version).to receive(:patch) { 0 }
    allow(Retrospring::Version).to receive(:suffix) { nil }
  end

  describe "#to_s" do
    context "without suffix" do
      it "should return the correct version string" do
        expect(Retrospring::Version.to_s).to eq("1984.0101.0")
      end
    end

    context "with suffix" do
      before(:each) do
        allow(Retrospring::Version).to receive(:suffix) { "+shutdown" }
      end

      it "should return the correct version string" do
        expect(Retrospring::Version.to_s).to eq("1984.0101.0+shutdown")
      end
    end
  end

  describe "#to_a" do
    it "should return the correct version as array" do
      expect(Retrospring::Version.to_a).to eq(%w[1984 0101 0])
    end
  end
end
