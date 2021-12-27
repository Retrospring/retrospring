# frozen_string_literal: true

require 'rails_helper'

describe SocialHelper::TwitterMethods, :type => :helper do
  let(:user) { FactoryBot.create(:user) }
  let(:answer) { FactoryBot.create(:answer, user: user,
                                  content: 'a' * 255,
                                  question_content: 'q' * 255) }

  before do
    stub_const("APP_CONFIG", {
      'hostname' => 'example.com',
      'https' => true,
      'items_per_page' => 5
    })
  end

  describe '#prepare_tweet' do
    context 'when the question and answer need to be shortened' do
      subject { prepare_tweet(answer) }

      it 'should return a properly formatted tweet' do
        expect(subject).to eq("#{'q' * 123}… — #{'a' * 124}… https://example.com/#{user.screen_name}/a/#{answer.id}")
      end
    end

    context 'when the question and answer are short' do
      before do
        answer.question.content = 'Why are raccoons so good?'
        answer.question.save!
        answer.content = 'Because they are good cunes.'
        answer.save!
      end

      subject { prepare_tweet(answer) }

      it 'should return a properly formatted tweet' do
        expect(subject).to eq("#{answer.question.content} — #{answer.content} https://example.com/#{user.screen_name}/a/#{answer.id}")
      end
    end
  end

  describe '#twitter_share_url' do
    subject { twitter_share_url(answer) }

    it 'should return a proper share link' do
      expect(subject).to eq("https://twitter.com/intent/tweet?text=#{CGI.escape(prepare_tweet(answer))}")
    end
  end
end