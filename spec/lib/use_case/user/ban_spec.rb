# frozen_string_literal: true

require "rails_helper"

RSpec.describe UseCase::User::Ban do
  let!(:target_user) { FactoryBot.create(:user) }
  let!(:source_user) { FactoryBot.create(:user) }
  let!(:question) { FactoryBot.create(:question, user: target_user) }
  let!(:inbox_entry) { FactoryBot.create(:inbox_entry, user: source_user, question: question) }
  let!(:report) { Report.create(type: "Reports::Question", target_user_id: target_user.id, target_id: question.id, user_id: source_user.id) }

  describe "#call" do
    context "when banning a user" do
      let(:expiry) { nil }

      context "when reason is spam" do
        let(:reason) { UseCase::User::Ban::REASON_SPAM }
        subject { described_class.call(target_user_id: target_user.id, source_user_id: source_user.id, reason: reason, expiry: expiry) }

        it "removes profile information" do
          subject
          target_user.reload

          expect(target_user.profile.display_name).to be_nil
          expect(target_user.profile.description).to eq("")
          expect(target_user.profile.location).to eq("")
          expect(target_user.profile.website).to eq("")
        end
      end

      context "when ban is permanent" do
        let(:reason) { "Other reason" }
        subject { described_class.call(target_user_id: target_user.id, source_user_id: source_user.id, reason: reason, expiry: expiry) }

        it "removes inbox entries for the questions sent by the user" do
          expect { subject }.to change { InboxEntry.joins(:question).where(questions: { user_id: target_user.id }).count }.from(1).to(0)
        end

        it "resolves reports related to the user" do
          expect { subject }.to change { Report.where(target_user_id: target_user.id, resolved: true).count }.from(0).to(1)
        end
      end

      context "when ban is temporary" do
        let(:expiry) { 1.week.from_now }
        let(:reason) { "Other reason" }
        subject { described_class.call(target_user_id: target_user.id, source_user_id: source_user.id, reason: reason, expiry: expiry) }

        it "does not remove inbox entries" do
          expect { subject }.not_to(change { InboxEntry.joins(:question).where(questions: { user_id: target_user.id }).count })
        end

        it "does not resolve reports" do
          expect { subject }.not_to(change { Report.where(target_user_id: target_user.id, resolved: true).count })
        end
      end
    end
  end
end
