# frozen_string_literal: true

require "rails_helper"

describe UseCase::Question::CreateFollowers do
  subject do
    UseCase::Question::CreateFollowers.call(
      source_user_id:    source_user.id,
      content:,
      author_identifier:,
    )
  end

  context "user is logged in" do
    before do
      followers.each do |target_user|
        target_user.follow source_user
      end
    end

    let(:source_user) { create(:user) }
    let(:followers) { create_list(:user, 5) }
    let(:content) { "content" }
    let(:author_identifier) { nil }

    it "creates question" do
      expect(subject[:resource]).to be_persisted
    end

    it "enqueues a QuestionWorker job" do
      followers.each do |target_user|
        expect(SendToInboxJob).to have_enqueued_sidekiq_job(target_user.id, subject[:resource].id)
      end
    end

    it "increments the asked count" do
      expect { subject }.to change { source_user.reload.asked_count }.by(1)
    end

    context "content is over 32768 characters long" do
      let(:content) { "a" * 32769 }

      it "raises an error" do
        expect { subject }.to raise_error(Errors::QuestionTooLong)
      end
    end
  end
end
