# frozen_string_literal: true

require "rails_helper"

describe MarkdownHelper, type: :helper do
  before do
    stub_const("APP_CONFIG", {
                 "hostname"       => "example.com",
                 "https"          => true,
                 "items_per_page" => 5,
                 "allowed_hosts"  => [
                   "twitter.com"
                 ]
               })
  end

  describe "#markdown" do
    it "should return the expected text" do
      expect(markdown("**Strong text**")).to eq("<p><strong>Strong text</strong></p>")
    end

    it "should transform mentions into links" do
      expect(markdown("@jake_weary")).to eq('<p><a href="/@jake_weary">@jake_weary</a></p>')
    end

    it "should escape text in links" do
      expect(markdown("[It's a link](https://example.com)")).to eq('<p><a href="/linkfilter?url=https%3A%2F%2Fexample.com" target="_blank" rel="nofollow">It\'s a link</a></p>')
      expect(markdown("[It's >a link](https://example.com)")).to eq('<p><a href="/linkfilter?url=https%3A%2F%2Fexample.com" target="_blank" rel="nofollow">It\'s &gt;a link</a></p>')
    end

    it "should escape HTML tags" do
      expect(markdown("I'm <h1>a test</h1>")).to eq("<p>I'm &lt;h1&gt;a test&lt;/h1&gt;</p>")
    end
  end

  describe "#strip_markdown" do
    it "should not return formatted text" do
      expect(strip_markdown("**Strong text**")).to eq("Strong text")
    end
  end

  describe "#twitter_markdown" do
    it "should not transform the mention" do
      expect(twitter_markdown("@test")).to eq("test")
    end

    it "should not strip weird hearts" do
      expect(twitter_markdown("<///3")).to eq("<///3")
    end
  end

  describe "#question_markdown" do
    it "should link allowed links without the linkfilter" do
      expect(question_markdown("https://twitter.com/retrospring")).to eq('<p><a href="https://twitter.com/retrospring" target="_blank" rel="nofollow">https://twitter.com/retrospring</a></p>')
    end

    it "should link untrusted links with the linkfilter" do
      expect(question_markdown("https://rrerr.net")).to eq('<p><a href="/linkfilter?url=https%3A%2F%2Frrerr.net" target="_blank" rel="nofollow">https://rrerr.net</a></p>')
    end

    it "should not process any markup aside of links" do
      expect(question_markdown("**your account has been disabled**, [click here to enable it again](https://evil.example.com)")).to eq('<p>your account has been disabled, <a href="/linkfilter?url=https%3A%2F%2Fevil.example.com" target="_blank" rel="nofollow">https://evil.example.com</a></p>')
      expect(question_markdown("> the important question is: will it blend?")).to eq("<p>the important question is: will it blend?</p>")
    end

    it "should not raise an exception if an invalid link is processed" do
      expect { question_markdown("https://example.com/example.質問") }.not_to raise_error
    end

    it "should not process invalid links" do
      expect(question_markdown("https://example.com/example.質問")).to eq("<p>https://example.com/example.質問</p>")
    end
  end

  describe "#raw_markdown" do
    it "should return the expected text" do
      expect(raw_markdown("# Heading")).to eq("<h1>Heading</h1>\n")
    end
  end

  describe "#get_markdown" do
    it "should return the contents of the specified file" do
      expect(get_markdown("spec/fixtures/markdown/test.md")).to eq("# Heading")
    end

    it "should return an error message on error" do
      expect(get_markdown("non/existant/path.md")).to eq("# Error reading #{Rails.root.join('non/existant/path.md')}")
    end
  end

  describe "#markdown_io" do
    it "should return the expected text" do
      expect(markdown_io("spec/fixtures/markdown/io.md")).to eq("<p><strong>Strong text</strong></p>")
    end
  end

  describe "#strip_markdown_io" do
    it "should return the expected text" do
      expect(strip_markdown_io("spec/fixtures/markdown/io.md")).to eq("Strong text")
    end
  end

  describe "#twitter_markdown_io" do
    let(:user) { FactoryBot.create(:user) }

    it "should return the expected text" do
      expect(twitter_markdown_io("spec/fixtures/markdown/twitter.md")).to eq("test")
    end
  end

  describe "#raw_markdown_io" do
    it "should return the expected text" do
      expect(raw_markdown_io("spec/fixtures/markdown/test.md")).to eq("<h1>Heading</h1>\n")
    end
  end
end
