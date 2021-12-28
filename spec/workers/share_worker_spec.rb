# frozen_string_literal: true

require 'rails_helper'

describe ShareWorker do
  let(:user) { FactoryBot.create(:user) }
  let(:answer) { FactoryBot.create(:answer, user: user) }
  let!(:service) { Services::Twitter.create!(type: 'Services::Twitter',
                                                    user: user) }

  before do
    stub_const("APP_CONFIG", {
      'hostname' => 'example.com',
      'anonymous_name' => 'Anonymous',
      'https' => true,
      'items_per_page' => 5,
      'sharing' => {
        'twitter' => {
          'consumer_key' => '',
        }
      }
    })
  end

  describe "#perform" do
    subject {
      Sidekiq::Testing.fake! do
        ShareWorker.perform_async(user.id, answer.id, 'twitter')
      end
    }

    context 'when answer doesn\'t exist' do
      it 'prevents the job from retrying and logs a message' do
        answer.destroy!
        Sidekiq.logger.should_receive(:info).with("Tried to post answer ##{answer.id} for user ##{user.id} to Twitter but the user/answer/service did not exist (likely deleted), will not retry.")
        expect { subject }.to change(ShareWorker.jobs, :size).by(1)
        expect { ShareWorker.drain }.to change(ShareWorker.jobs, :size).by(-1)
      end
    end

    context 'when answer exists' do
      it 'handles Twitter::Error::DuplicateStatus' do
        allow_any_instance_of(Services::Twitter).to receive(:post).with(answer).and_raise(Twitter::Error::DuplicateStatus)
        Sidekiq.logger.should_receive(:info).with("Tried to post answer ##{answer.id} from user ##{user.id} to Twitter but the status was already posted.")
        subject
        ShareWorker.drain
      end

      it 'handles Twitter::Error::Unauthorized' do
        allow_any_instance_of(Services::Twitter).to receive(:post).with(answer).and_raise(Twitter::Error::Unauthorized)
        Sidekiq.logger.should_receive(:info).with("Tried to post answer ##{answer.id} from user ##{user.id} to Twitter but the token has exired or been revoked.")
        subject
        ShareWorker.drain
      end

      it 'retries on unhandled exceptions' do
        expect { subject }.to change(ShareWorker.jobs, :size).by(1)
        Sidekiq.logger.should_receive(:info)
        expect { ShareWorker.drain }.to raise_error(Twitter::Error::BadRequest)
      end
    end
  end
end
