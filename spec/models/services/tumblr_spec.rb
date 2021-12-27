# frozen_string_literal: true

require 'rails_helper'

describe Services::Tumblr do
  describe "#post" do
    let(:user) { FactoryBot.create(:user) }
    let(:service) { Services::Tumblr.create(user: user) }
    let(:answer) { FactoryBot.create(:answer, user: user,
                                     content: 'a' * 255,
                                     question_content: 'q' * 255) }
    let(:tumblr_client) { instance_double(Tumblr::Client) }

    before do
      allow(Tumblr::Client).to receive(:new).and_return(tumblr_client)
      allow(tumblr_client).to receive(:text)
      stub_const("APP_CONFIG", {
        'hostname' => 'example.com',
        'anonymous_name' => 'Anonymous',
        'https' => true,
        'items_per_page' => 5,
        'sharing' => {
          'tumblr' => {
            'consumer_key' => 'AAA',
          }
        }
      })
    end
    
    it "posts a text-post" do
      answer.question.content = 'Why are raccoons so good?'
      answer.question.author_is_anonymous = true
      answer.question.save!
      answer.content = 'Because they are good cunes.'
      answer.save!

      service.post(answer)

      expect(tumblr_client).to have_received(:text).with(
        service.uid,
        title: 'Anonymous asked: Why are raccoons so good?',
        body: "Because they are good cunes.\n\n[Smile or comment on the answer here](https://example.com/#{user.screen_name}/a/#{answer.id})",
        format: 'markdown',
        tweet: 'off'
      )
    end
  end
end