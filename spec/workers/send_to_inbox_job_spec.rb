# frozen_string_literal: true

require "rails_helper"

describe SendToInboxJob do
  describe "#perform" do
    let(:user) { FactoryBot.create(:user) }
    let(:user_id) { user.id }
    let(:content) { Faker::Lorem.sentence }
    let(:question_id) { 621 }
    let(:follower) { FactoryBot.create(:user) }
    let(:follower_id) { follower.id }

    subject { described_class.new.perform(follower_id, question_id) }

    it "does nothing" do
      subject
    end
  end
end
