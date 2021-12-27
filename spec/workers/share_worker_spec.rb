# frozen_string_literal: true

require 'rails_helper'

describe ShareWorker do
  let(:user) { FactoryBot.create(:user) }
  let(:answer) { FactoryBot.create(:answer, user: user) }

  describe "#perform" do
    subject { ShareWorker.new.perform(user.id, answer.id, 'twitter') }

    before do
      Service.create!(type: 'Services::Twitter',
                      user: user)
    end

    context 'when answer doesn\'t exist' do
      it 'prevents the job from retrying and logs a message' do
        answer.destroy!
        Sidekiq.logger.should_receive(:info)
        subject
        expect(ShareWorker.jobs.size).to eq(0)
      end
    end
  end
end
