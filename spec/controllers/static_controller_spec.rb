# frozen_string_literal: true

require "rails_helper"

describe StaticController, type: :controller do
  describe "#about" do
    subject { get :about }
    
    before(:each) {
      FactoryBot.create(:user, { confirmed_at: Time.now, answered_count: 1, asked_count: 1 })
      FactoryBot.create(:user, { permanently_banned: true })
      FactoryBot.create(:user, { banned_until: Time.now + 10.days })
      FactoryBot.create(:user, { confirmed_at: Time.now })
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
end