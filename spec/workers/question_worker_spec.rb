# frozen_string_literal: true

require "rails_helper"

describe QuestionWorker do
  describe "#perform" do
    let(:user) { FactoryBot.create(:user) }
    let(:user_id) { user.id }
    let(:question_id) { 621 }

    subject { described_class.new.perform(user_id, question_id) }

    it "does nothing" do
      subject
    end
  end
end
