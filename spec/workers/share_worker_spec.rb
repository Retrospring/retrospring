# frozen_string_literal: true

require "rails_helper"

describe ShareWorker do
  let(:user) { FactoryBot.create(:user) }
  let(:answer) { FactoryBot.create(:answer, user: user) }
  let!(:service) do
    Services::Twitter.create!(type: "Services::Twitter",
                              user: user)
  end

  before do
    stub_const("APP_CONFIG", {
                 "hostname"       => "example.com",
                 "anonymous_name" => "Anonymous",
                 "https"          => true,
                 "items_per_page" => 5,
                 "sharing"        => {
                   "twitter" => {
                     "consumer_key" => ""
                   }
                 }
               })
  end

  describe "#perform" do
    before do
      allow(Sidekiq.logger).to receive(:info)
    end

    subject do
      Sidekiq::Testing.fake! do
        ShareWorker.perform_async(user.id, answer.id, "twitter")
      end
    end

    context "when answer doesn't exist" do
      it "prevents the job from retrying and logs a message" do
        answer.destroy!
        expect { subject }.to change(ShareWorker.jobs, :size).by(1)
        expect { ShareWorker.drain }.to change(ShareWorker.jobs, :size).by(-1)
        expect(Sidekiq.logger).to have_received(:info).with("Tried to post answer ##{answer.id} for user ##{user.id} to Twitter but the user/answer/service did not exist (likely deleted), will not retry.")
      end
    end

    context "when answer exists" do
      it "handles Twitter::Error::DuplicateStatus" do
        allow_any_instance_of(Services::Twitter).to receive(:post).with(answer).and_raise(Twitter::Error::DuplicateStatus)
        subject
        ShareWorker.drain
        expect(Sidekiq.logger).to have_received(:info).with("Tried to post answer ##{answer.id} from user ##{user.id} to Twitter but the status was already posted.")
      end

      it "handles Twitter::Error::Unauthorized" do
        allow_any_instance_of(Services::Twitter).to receive(:post).with(answer).and_raise(Twitter::Error::Unauthorized)
        subject
        ShareWorker.drain
        expect(Sidekiq.logger).to have_received(:info).with("Tried to post answer ##{answer.id} from user ##{user.id} to Twitter but the token has exired or been revoked.")
      end

      it "retries on unhandled exceptions" do
        expect { subject }.to change(ShareWorker.jobs, :size).by(1)
        expect { ShareWorker.drain }.to raise_error(Twitter::Error::BadRequest)
        expect(Sidekiq.logger).to have_received(:info)
      end
    end
  end
end
