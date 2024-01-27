# frozen_string_literal: true

require "rails_helper"

describe Scheduler::InboxCleanupScheduler do
  let(:user) { FactoryBot.create(:user) }
  let(:inbox) { FactoryBot.create(:inbox_entry, user:) }

  describe "#perform" do
    before do
      inbox.question_id = nil
      inbox.save(validate: false)
    end

    subject { described_class.new.perform }

    it "should delete orphaned inbox entries" do
      expect { subject }
        .to(
          change { InboxEntry.where(question_id: nil).count }
            .from(1)
            .to(0),
        )
    end
  end
end
