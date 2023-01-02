# frozen_string_literal: true

require "rails_helper"

describe UseCase::MuteRule::Create do
  subject { UseCase::MuteRule::Create.call(user:, phrase:) }

  context "user passed" do
    let(:user) { FactoryBot.create(:user) }

    context "phrase is empty" do
      let(:phrase) { "" }

      it "does not create the rule" do
        expect { subject }.not_to(change { MuteRule.count })
      end
    end

    context "phrase is non-empty" do
      let(:phrase) { "test" }

      it "creates the rule" do
        expect { subject }.to change { MuteRule.count }.by(1)
      end
    end
  end
end
