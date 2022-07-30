# frozen_string_literal: true

require "rails_helper"
require "errors"
require "use_case/question/create_followers"

describe UseCase::Question::CreateFollowers do
  subject do
    UseCase::Question::CreateFollowers.call(
      source_user_id:    source_user.id,
      content:           content,
      author_identifier: author_identifier
    )
  end

  context "user is logged in" do
    let(:source_user) { create(:user) }
    let(:content) { "content" }
    let(:author_identifier) { nil }

    it "creates question" do
      expect(subject[:resource]).to be_persisted
    end

    it "enqueues a QuestionWorker job" do
      expect(QuestionWorker).to have_enqueued_sidekiq_job(source_user.id, subject[:resource].id)
    end
  end
end
