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
                 ],
               },)
  end

  describe "#markdown" do
    it "should return the expected text" do
      expect(markdown("**Strong text**")).to eq("<p><strong>Strong text</strong></p>")
    end

    it "does not transform mentions into links" do
      expect(markdown("@jake_weary")).to eq("<p>@jake_weary</p>")
    end

    it "should escape text in links" do
      expect(markdown("[It's a link](https://example.com)")).to eq('<p><a href="/linkfilter?url=https%3A%2F%2Fexample.com" target="_blank" rel="nofollow">It\'s a link</a></p>')
      expect(markdown("[It's >a link](https://example.com)")).to eq('<p><a href="/linkfilter?url=https%3A%2F%2Fexample.com" target="_blank" rel="nofollow">It\'s &gt;a link</a></p>')
    end

    it "should escape HTML tags" do
      expect(markdown("I'm <h1>a test</h1>")).to eq("<p>I'm &lt;h1&gt;a test&lt;/h1&gt;</p>")
    end

    it "should turn line breaks into <br> tags" do
      expect(markdown("Some\ntext")).to eq("<p>Some<br>\ntext</p>")
    end
  end

  describe "#strip_markdown" do
    it "should not return formatted text" do
      expect(strip_markdown("**Strong text**")).to eq("Strong text")
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

  describe "#raw_markdown_io" do
    it "should return the expected text" do
      expect(raw_markdown_io("spec/fixtures/markdown/test.md")).to eq("<h1>Heading</h1>\n")
    end
  end
end
