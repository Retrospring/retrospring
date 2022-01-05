# frozen_string_literal: true

require 'rails_helper'

describe SocialHelper::TumblrMethods, :type => :helper do
  let(:user) { FactoryBot.create(:user) }
  let(:answer) { FactoryBot.create(:answer, user: user,
                                    content: 'aaaa',
                                    question_content: 'q') }

  before do
    stub_const("APP_CONFIG", {
      'hostname' => 'example.com',
      'anonymous_name' => 'Anonymous',
      'https' => true,
      'items_per_page' => 5,
      'sharing' => {}
    })
  end

  describe '#tumblr_title' do
    context 'Asker is anonymous' do
      subject { tumblr_title(answer) }

      it 'should return a proper title' do
        expect(subject).to eq('Anonymous asked: q')
      end
    end

    context 'Asker is known' do
      before do
        @user = FactoryBot.create(:user)
        answer.question.user = @user
        answer.question.author_is_anonymous = false
      end

      subject { tumblr_title(answer) }

      it 'should return a proper title' do
        expect(subject).to eq("#{answer.question.user.profile.display_name} asked: q")
      end
    end
  end

  describe '#tumblr_body' do
    subject { tumblr_body(answer) }

    it 'should return a proper body' do
      expect(subject).to eq("aaaa\n\n[Smile or comment on the answer here](https://example.com/#{answer.user.screen_name}/a/#{answer.id})")
    end
  end

  describe '#tumblr_share_url' do
    subject { tumblr_share_url(answer) }

    it 'should return a proper share link' do
        expect(subject).to eq("https://www.tumblr.com/widgets/share/tool?shareSource=legacy&posttype=text&title=#{CGI.escape(tumblr_title(answer))}&url=#{CGI.escape("https://example.com/#{answer.user.screen_name}/a/#{answer.id}")}&caption=&content=#{CGI.escape(tumblr_body(answer))}")
    end
  end
end
