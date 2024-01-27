# frozen_string_literal: true

require "rails_helper"

describe QuestionWorker do
  describe "#perform" do
    let(:user) { FactoryBot.create(:user) }
    let(:user_id) { user.id }
    let(:content) { Faker::Lorem.sentence }
    let(:question) { FactoryBot.create(:question, content:, user:) }
    let(:question_id) { question.id }

    before do
      5.times do
        other_user = FactoryBot.create(:user)
        other_user.follow(user)
      end
    end

    subject { described_class.new.perform(user_id, question_id) }

    it "places the question in the inbox of the user's followers" do
      expect { subject }
        .to(
          change { InboxEntry.where(user_id: user.followers.ids, question_id:, new: true).count }
            .from(0)
            .to(5)
        )
    end

    it "respects mute rules" do
      question.content = "Some spicy question text"
      question.save

      MuteRule.create(user_id: user.followers.first.id, muted_phrase: "spicy")

      expect { subject }
        .to(
          change { InboxEntry.where(user_id: user.followers.ids, question_id:, new: true).count }
            .from(0)
            .to(4)
        )
    end

    it "respects inbox locks" do
      user.followers.first.update(privacy_lock_inbox: true)

      expect { subject }
        .to(
          change { InboxEntry.where(user_id: user.followers.ids, question_id:, new: true).count }
            .from(0)
            .to(4)
        )
    end

    it "does not send questions to banned users" do
      user.followers.first.ban

      expect { subject }
        .to(
          change { InboxEntry.where(user_id: user.followers.ids, question_id:, new: true).count }
            .from(0)
            .to(4)
        )
    end

    context "receiver has push notifications enabled" do
      let(:receiver) { FactoryBot.create(:user) }

      before do
        Rpush::Webpush::App.create(
          name:        "webpush",
          certificate: { public_key: "AAAA", private_key: "AAAA", subject: "" }.to_json,
          connections: 1
        )

        WebPushSubscription.create!(
          user:         receiver,
          subscription: {
            endpoint: "This will not be used",
            keys:     {},
          }
        )
        receiver.follow(user)
      end

      it "sends notifications" do
        expect { subject }
          .to(
            change { Rpush::Webpush::Notification.count }
              .from(0)
              .to(1)
          )
      end
    end

    context "long question" do
      let(:content) { "x" * 1000 }

      it "sends to recipients who allow long questions" do
        user.followers.first.profile.update(allow_long_questions: true)

        expect { subject }
          .to(
            change { InboxEntry.where(user_id: user.followers.ids, question_id:, new: true).count }
              .from(0)
              .to(1)
          )
      end
    end
  end
end
