# frozen_string_literal: true

require 'rails_helper'

describe Services::Twitter do
  describe "#post" do
    let(:user) { FactoryBot.create(:user) }
    let(:service) { Services::Twitter.create(user: user) }
    let(:answer) { FactoryBot.create(:answer, user: user,
                                     content: 'a' * 255,
                                     question_content: 'q' * 255) }
    let(:twitter_client) { instance_double(Twitter::REST::Client) }

    before do
      allow(Twitter::REST::Client).to receive(:new).and_return(twitter_client)
      allow(twitter_client).to receive(:update!)
      stub_const("APP_CONFIG", {
        'hostname' => 'example.com',
        'https' => true,
        'items_per_page' => 5,
        'sharing' => {
          'twitter' => {
            'consumer_key' => 'AAA',
          }
        }
      })
    end

    it "posts a shortened tweet" do
      service.post(answer)

      expect(twitter_client).to have_received(:update!).with("#{'q' * 123}… — #{'a' * 124}… https://example.com/@#{user.screen_name}/a/#{answer.id}")
    end
    
    it "posts an un-shortened tweet" do
      answer.question.content = 'Why are raccoons so good?'
      answer.question.save!
      answer.content = 'Because they are good cunes.'
      answer.save!

      service.post(answer)

      expect(twitter_client).to have_received(:update!).with("#{answer.question.content} — #{answer.content} https://example.com/@#{user.screen_name}/a/#{answer.id}")
    end
  end
end