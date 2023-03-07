# frozen_string_literal: true

require "rails_helper"

describe User::NotificationMethods do
  context "given a user" do
    let(:user) { FactoryBot.create(:user) }

    describe "#unread_notification_count" do
      subject { user.unread_notification_count }

      context "user has no notifications" do
        it "should return nil" do
          expect(subject).to eq(nil)
        end
      end

      context "user has a notification" do
        let(:other_user) { FactoryBot.create(:user) }

        before do
          other_user.follow(user)
        end

        it "should return 1" do
          expect(subject).to eq(1)
        end
      end
    end
  end
end
