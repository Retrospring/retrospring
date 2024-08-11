# frozen_string_literal: true

require "rails_helper"

describe AboutController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "advanced layout is enabled" do
      before do
        allow(APP_CONFIG).to receive(:dig).with(:features, :advanced_frontpage, :enabled).and_return(true)
      end

      it "renders the correct template" do
        subject
        expect(response).to render_template("about/index_advanced")
      end
    end

    context "advanced layout is disabled" do
      before do
        allow(APP_CONFIG).to receive(:dig).with(:features, :advanced_frontpage, :enabled).and_return(false)
      end

      it "renders the correct template" do
        subject
        expect(response).to render_template("about/index")
      end
    end
  end

  describe "#about" do
    subject { get :about }

    before(:each) do
      FactoryBot.create(:user, { confirmed_at: Time.current, answered_count: 1 })
      FactoryBot.create(:user, { confirmed_at: Time.current, answered_count: 1 }).ban
      FactoryBot.create(:user, { confirmed_at: Time.current })
      FactoryBot.create(:user, { confirmed_at: Time.current }).ban
    end

    it "shows the correct user count" do
      subject
      expect(assigns(:users)).to eq(1)
    end
  end
end
