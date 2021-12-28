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
        Sidekiq.logger.should_receive(:info)
        expect { subject }.to change(ShareWorker.jobs, :size).by(1)
        expect { ShareWorker.drain }.to change(ShareWorker.jobs, :size).by(-1)
      end
    end

    context 'when answer exists' do
      it 'retries on unhandled exceptions' do
        expect { subject }.to change(ShareWorker.jobs, :size).by(1)
        expect { ShareWorker.drain }.to raise_error(Twitter::Error::BadRequest)
      end
    end
  end
end
