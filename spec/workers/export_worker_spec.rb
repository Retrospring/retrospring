# frozen_string_literal: true

require "rails_helper"

describe ExportWorker do
  let(:user) { FactoryBot.create(:user) }

  describe "#perform" do
    let(:exporter_double) { double("Exporter") }

    before do
      # stub away the testing of the exporter itself since it is done in lib/exporter_spec
      allow(exporter_double).to receive(:export)
      allow(Exporter).to receive(:new).and_return(exporter_double)
    end

    subject { described_class.new.perform(user.id) }

    it "creates an exported notification" do
      expect { subject }.to change { Notification::DataExported.count }.by(1)

      notification = Notification::DataExported.last
      expect(notification.target_id).to eq(user.id)
      expect(notification.target_type).to eq("User::DataExport")
      expect(notification.recipient).to eq(user)
      expect(notification.new).to be true
    end
  end
end
