# frozen_string_literal: true

require "rails_helper"

describe QuestionWorker do
  describe "#perform" do
    let(:user) { FactoryBot.create(:user) }
    let(:user_id) { user.id }
    let(:question) { FactoryBot.create(:question, user: user) }
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
          change { Inbox.where(user_id: user.followers.ids, question_id: question_id, new: true).count }
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
          change { Inbox.where(user_id: user.followers.ids, question_id: question_id, new: true).count }
            .from(0)
            .to(4)
        )
    end
  end
end
