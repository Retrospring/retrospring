# frozen_string_literal: true

require "rails_helper"

describe User::InboxMethods do
  context "given a user" do
    let(:user) { FactoryBot.create(:user) }

    describe "#unread_inbox_count" do
      subject { user.unread_inbox_count }

      context "user has no questions in their inbox" do
        it "should return nil" do
          expect(subject).to eq(nil)
        end
      end

      context "user has 1 question in their inbox" do
        # FactoryBot seems to have issues with setting the +new+ field on inbox entries
        # so we can create it manually instead
        let!(:inbox) { Inbox.create(question: FactoryBot.create(:question), user:, new: true) }

        it "should return 1" do
          expect(subject).to eq(1)
        end
      end
    end
  end
end
