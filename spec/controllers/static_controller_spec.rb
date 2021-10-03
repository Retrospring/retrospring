# frozen_string_literal: true

require "rails_helper"

describe StaticController, type: :controller do
  describe "#about" do
    subject { get :about }
    
    before(:each) {
      User.create(screen_name: 'very_valid_user', confirmed_at: Time.now, answered_count: 1, asked_count: 1)
      User.create(screen_name: 'big_ben', permanently_banned: true)
      User.create(screen_name: 'youre_mom', banned_until: Time.now + 10.days)
      User.create(screen_name: 'silence_fox', confirmed_at: Time.now)
    }

    it "shows the correct user count" do
      subject
      expect(assigns(:users)).to eq(1)
    end
  end
end