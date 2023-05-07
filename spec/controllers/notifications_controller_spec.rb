# frozen_string_literal: true

require "rails_helper"

describe NotificationsController do
  include ActiveSupport::Testing::TimeHelpers

  describe "#index" do
    subject { get :index, params: { type: :new } }

    let(:original_notifications_updated_at) { 1.day.ago }
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
    end

    context "user has no notifications" do
      it "should show an empty list" do
        subject
        expect(response).to render_template(:index)

        expect(controller.instance_variable_get(:@notifications)).to be_empty
      end
    end

    context "user has notifications" do
      let(:other_user) { FactoryBot.create(:user) }
      let(:another_user) { FactoryBot.create(:user) }
      let(:question) { FactoryBot.create(:question, user:) }
      let!(:answer) { FactoryBot.create(:answer, question:, user: other_user) }
      let!(:subscription) { Subscription.create(user:, answer:) }
      let!(:comment) { FactoryBot.create(:comment, answer:, user: other_user) }

      it "should show a list of notifications" do
        subject
        expect(response).to render_template(:index)
        expect(controller.instance_variable_get(:@notifications)).to have_attributes(size: 2)
      end

      it "marks notifications as read" do
        expect { subject }.to change { Notification.for(user).where(new: true).count }.from(2).to(0)
      end

      it "updates the the timestamp used for caching" do
        user.update(notifications_updated_at: original_notifications_updated_at)
        travel 1.second do
          expect { subject }.to change { user.reload.notifications_updated_at.floor }.from(original_notifications_updated_at.floor).to(Time.now.utc.floor)
        end
      end
    end
  end

  describe "#read" do
    subject { post :read, format: :turbo_stream }

    let(:recipient) { FactoryBot.create(:user) }
    let(:notification_count) { rand(8..20) }

    context "user has some unread notifications" do
      before do
        notification_count.times do
          FactoryBot.create(:user).follow(recipient)
        end

        sign_in(recipient)
      end

      it "marks all notifications as read" do
        expect { subject }.to change { Notification.where(recipient:, new: true).count }.from(notification_count).to(0)
      end
    end
  end
end
