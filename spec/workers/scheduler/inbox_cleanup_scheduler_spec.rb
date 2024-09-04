# frozen_string_literal: true

require "rails_helper"

describe Scheduler::InboxCleanupScheduler do
  let(:user) { FactoryBot.create(:user) }

  describe "#perform" do
    subject { described_class.new.perform }

    it "does nothing" do
      subject
    end
  end
end
