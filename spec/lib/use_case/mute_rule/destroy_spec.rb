# frozen_string_literal: true

require "rails_helper"

describe UseCase::MuteRule::Destroy do
  subject { UseCase::MuteRule::Destroy.call(rule:) }

  context "rule exists" do
    let(:user) { FactoryBot.create(:user) }
    let(:rule) { MuteRule.create(user:, muted_phrase: "test") }

    it "deletes the mute rule" do
      expect { subject }.to change { MuteRule.exists?(rule.id) }.from(true).to(false)
    end
  end
end
