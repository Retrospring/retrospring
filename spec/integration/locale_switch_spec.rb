# frozen_string_literal: true

require "rails_helper"
require "nokogiri"

describe "locale switching", type: :request do
  matcher :have_html_lang do |expected_lang|
    description { %(have the HTML "lang" attribute set to #{expected_lang.inspect}) }

    match do |result|
      Nokogiri::HTML.parse(result).css("html[lang=#{expected_lang}]").size == 1
    end
  end

  context "when user not signed in" do
    it "uses the default :en locale" do
      get "/"
      expect(response.body).to have_html_lang "en"
      expect(response.cookies["lang"]).to eq "en"
    end

    context "when ?lang param is given" do
      it "changes the locale" do
        # 1. ensure we start with the default :en locale
        get "/"
        expect(response.body).to have_html_lang "en"
        expect(response.cookies["lang"]).to eq "en"

        # 2. switch the language to en-xx
        get "/?lang=en-xx"
        expect(response.body).to have_html_lang "en-xx"
        expect(response.cookies["lang"]).to eq "en-xx"

        # 3. remove the language parameter again
        get "/"
        expect(response.body).to have_html_lang "en-xx"
        expect(response.cookies["lang"]).to be_nil # no new cookie here, it's already en-xx
      end
    end
  end

  context "when user is signed in" do
    let(:user) { FactoryBot.create(:user, password: "test1234", locale:) }
    let(:locale) { "en" }

    before do
      post "/sign_in", params: { user: { login: user.email, password: user.password } }
    end

    it "uses the en locale" do
      get "/"
      expect(response.body).to have_html_lang "en"
      expect(response.cookies["lang"]).to be_nil # no new cookie here, already set by the sign in
    end

    context "when ?lang param is given" do
      it "changes the locale" do
        # 1. ensure we start with the :en locale
        get "/"
        expect(response.body).to have_html_lang "en"
        expect(response.cookies["lang"]).to be_nil # no new cookie here, already set by the sign in

        # 2. switch the language to en-xx
        expect { get "/?lang=en-xx" }.to change { user.reload.locale }.from("en").to("en-xx")
        expect(response.body).to have_html_lang "en-xx"
        expect(response.cookies["lang"]).to eq "en-xx"

        # 3. remove the language parameter again
        get "/"
        expect(response.body).to have_html_lang "en-xx"
        expect(response.cookies["lang"]).to be_nil # no new cookie here, it's already en-xx
      end
    end

    context "when user has a different locale set" do
      let(:locale) { "fi" }

      it "uses the different locale" do
        get "/"
        expect(response.body).to have_html_lang "fi"
        expect(response.cookies["lang"]).to be_nil # no new cookie here, already set by the sign in
      end
    end
  end
end
