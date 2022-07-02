# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserBan, type: :model do
  describe "validations" do
    it { should belong_to(:user) }
    it { should belong_to(:banned_by).class_name("User").optional }
  end

  describe "scopes" do
    describe ".current" do
      let(:user) { FactoryBot.create(:user) }
      let!(:current_ban) { UserBan.create(user: user, expires_at: Time.now.utc + 1.day) }
      let!(:expired_ban) { UserBan.create(user: user, expires_at: Time.now.utc - 1.day) }

      it "returns only current bans" do
        expect(UserBan.current).to eq([current_ban])
      end
    end
  end

  describe "#permanent?" do
    let(:user) { FactoryBot.create(:user) }
    let(:ban) { UserBan.create(user: user, expires_at: expires_at) }

    context "ban is permanent" do
      let(:expires_at) { nil }

      it "returns true" do
        expect(ban.permanent?).to eq(true)
      end
    end

    context "ban is not permanent" do
      let(:expires_at) { Time.now.utc + 1.day }

      it "returns false" do
        expect(ban.permanent?).to be false
      end
    end
  end

  describe "#current?" do
    let(:user) { FactoryBot.create(:user) }
    let(:ban) { UserBan.create(user: user, expires_at: expires_at) }

    context "ban is current" do
      let(:expires_at) { Time.now.utc + 1.day }

      it "returns true" do
        expect(ban.current?).to eq(true)
      end
    end

    context "ban is not current" do
      let(:expires_at) { Time.now.utc - 1.day }

      it "returns false" do
        expect(ban.current?).to eq(false)
      end
    end
  end
end
