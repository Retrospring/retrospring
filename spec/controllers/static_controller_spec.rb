# frozen_string_literal: true

require "rails_helper"

describe StaticController, type: :controller do
  describe "#about" do
    subject { get :about }

    before(:each) {
      FactoryBot.create(:user, { confirmed_at: Time.current, answered_count: 1 })
      FactoryBot.create(:user, { confirmed_at: Time.current, answered_count: 1 }).ban
      FactoryBot.create(:user, { confirmed_at: Time.current })
      FactoryBot.create(:user, { confirmed_at: Time.current }).ban
    }

    it "shows the correct user count" do
      subject
      expect(assigns(:users)).to eq(1)
    end
  end

  describe "#linkfilter" do
    context "called without an url" do
      subject { get :linkfilter }

      it 'should redirect to the root page' do
        subject
        expect(response).to redirect_to(root_path)
      end
    end

    context "called with an url" do
      subject { get :linkfilter, params: { url: 'https://google.com' } }

      it 'should show the passed url' do
        subject
        expect(assigns(:link)).to eq('https://google.com')
      end
    end
  end

  describe "#webapp_manifest" do
    subject { get :webapp_manifest }

    before do
      stub_const("APP_CONFIG", {
                   "site_name"      => "Specspring",
                   "hostname"       => "test.host",
                   "https"          => false,
                   "items_per_page" => 5
                 })
    end

    it "returns a web app manifest" do
      subject
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)

      expect(body["name"]).to eq("Specspring")
      expect(body["start_url"]).to eq("http://test.host/?source=pwa")
      expect(body["scope"]).to eq("http://test.host/")
      expect(body["theme_color"]).to eq("#5e35b1")
    end

    context "user with a theme is logged in" do
      let(:user) { FactoryBot.create(:user) }
      let!(:theme) { FactoryBot.create(:theme, user: user) }

      before do
        sign_in(user)
      end

      it "uses the user's theme" do
        subject
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["theme_color"]).to eq("#8e8cd8")
      end
    end
  end
end