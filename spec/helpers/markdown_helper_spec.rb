require "rails_helper"

describe MarkdownHelper, :type => :helper do
  before do
    stub_const("APP_CONFIG", {
      'hostname' => 'example.com',
      'https' => true,
      'items_per_page' => 5,
      'allowed_hosts' => [
        'twitter.com'
      ]
    })
  end

  describe '#markdown' do
    it 'should return the expected text' do
      expect(markdown('**Strong text**')).to eq('<p><strong>Strong text</strong></p>')
    end

    it 'should transform mentions into links' do
      expect(markdown('@jake_weary')).to eq('<p><a href="/jake_weary">@jake_weary</a></p>')
    end
  end

  describe '#strip_markdown' do
    it 'should not return formatted text' do
      expect(strip_markdown('**Strong text**')).to eq('Strong text')
    end
  end

  describe '#twitter_markdown' do
    context 'mentioned user has Twitter connected' do
      let(:user) { FactoryBot.create(:user) }
      let(:service) { Services::Twitter.create(user: user) }
  
      before do
        service.nickname = 'test'
        service.save!
      end

      it 'should transform a internal mention to a Twitter mention' do
        expect(twitter_markdown("@#{user.screen_name}")).to eq('@test')
      end
    end

    context 'mentioned user doesnt have Twitter connected' do
      it 'should not transform the mention' do
        expect(twitter_markdown('@test')).to eq('test')
      end
    end
  end

  describe '#question_markdown' do
    it 'should link allowed links without the linkfilter' do
      expect(question_markdown('https://twitter.com/retrospring')).to eq('<p><a href="https://twitter.com/retrospring" target="_blank">https://twitter.com/retrospring</a></p>')
    end

    it 'should link untrusted links with the linkfilter' do
      expect(question_markdown('https://rrerr.net')).to eq('<p><a href="/linkfilter?url=https%3A%2F%2Frrerr.net" target="_blank">https://rrerr.net</a></p>')
    end
  end

  describe '#raw_markdown' do
    it 'should return the expected text' do
      expect(raw_markdown('# Heading')).to eq("<h1>Heading</h1>\n")
    end
  end

  describe '#get_markdown' do
    it 'should return the contents of the specified file' do
      expect(get_markdown('spec/fixtures/markdown/test.md')).to eq("# Heading")
    end

    it 'should return an error message on error' do
      expect(get_markdown('non/existant/path.md')).to eq("# Error reading #{Rails.root}/non/existant/path.md")
    end
  end

  describe '#markdown_io' do
    it 'should return the expected text' do
      expect(markdown_io('spec/fixtures/markdown/io.md')).to eq('<p><strong>Strong text</strong></p>')
    end
  end

  describe '#strip_markdown_io' do
    it 'should return the expected text' do
      expect(strip_markdown_io('spec/fixtures/markdown/io.md')).to eq('Strong text')
    end
  end

  describe '#twitter_markdown_io' do
    let(:user) { FactoryBot.create(:user) }
    let(:service) { Services::Twitter.create(user: user) }

    before do
      user.screen_name = 'test'
      user.save!
      service.nickname = 'ObamaGaming'
      service.save!
    end

    it 'should return the expected text' do
      expect(twitter_markdown_io('spec/fixtures/markdown/twitter.md')).to eq('@ObamaGaming')
    end
  end

  describe '#raw_markdown_io' do
    it 'should return the expected text' do
      expect(raw_markdown_io('spec/fixtures/markdown/test.md')).to eq("<h1>Heading</h1>\n")
    end
  end
end