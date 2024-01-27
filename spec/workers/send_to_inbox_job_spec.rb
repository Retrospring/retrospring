# frozen_string_literal: true

require "rails_helper"

describe SendToInboxJob do
  describe "#perform" do
    let(:user) { FactoryBot.create(:user) }
    let(:user_id) { user.id }
    let(:content) { Faker::Lorem.sentence }
    let(:question) { FactoryBot.create(:question, content:, user:) }
    let(:question_id) { question.id }
    let(:follower) { FactoryBot.create(:user) }
    let(:follower_id) { follower.id }

    before do
      follower.follow(user)
    end

    subject { described_class.new.perform(follower_id, question_id) }

    it "places the question in the inbox of the user's followers" do
      expect { subject }
        .to(
          change { InboxEntry.where(user_id: follower_id, question_id:, new: true).count }
            .from(0)
            .to(1),
        )
    end

    it "respects mute rules" do
      question.content = "Some spicy question text"
      question.save

      MuteRule.create(user_id: follower_id, muted_phrase: "spicy")

      subject
      expect(InboxEntry.where(user_id: follower_id, question_id:, new: true).count).to eq(0)
    end

    it "respects inbox locks" do
      follower.update(privacy_lock_inbox: true)

      subject
      expect(InboxEntry.where(user_id: follower_id, question_id:, new: true).count).to eq(0)
    end

    it "does not send questions to banned users" do
      follower.ban

      subject
      expect(InboxEntry.where(user_id: follower_id, question_id:, new: true).count).to eq(0)
    end

    context "receiver has push notifications enabled" do
      before do
        Rpush::Webpush::App.create(
          name:        "webpush",
          certificate: { public_key: "AAAA", private_key: "AAAA", subject: "" }.to_json,
          connections: 1,
        )

        WebPushSubscription.create!(
          user:         follower,
          subscription: {
            endpoint: "This will not be used",
            keys:     {},
          },
        )
      end

      it "sends notifications" do
        expect { subject }
          .to(
            change { Rpush::Webpush::Notification.count }
              .from(0)
              .to(1),
          )
      end
    end

    context "long question" do
      let(:content) { "x" * 1000 }

      it "sends to recipients who allow long questions" do
        follower.profile.update(allow_long_questions: true)

        expect { subject }
          .to(
            change { InboxEntry.where(user_id: follower_id, question_id:, new: true).count }
              .from(0)
              .to(1),
          )
      end

      it "does not send to recipients who do not allow long questions" do
        subject
        expect(InboxEntry.where(user_id: follower_id, question_id:, new: true).count).to eq(0)
      end
    end
  end
end
