# frozen_string_literal: true

require "rails_helper"

describe AboutController, type: :controller do
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
