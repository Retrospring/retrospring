# frozen_string_literal: true

require "rails_helper"

describe UseCase::Reaction::Destroy do
  shared_examples_for "valid target type" do
    before do
      user.smile target
    end

    it "destroys a reaction" do
      expect { subject }.to change { target.reload.smile_count }.by(-1)
    end
  end

  subject { UseCase::Reaction::Destroy.call(source_user: user, target:) }

  let(:user) { FactoryBot.create(:user) }

  context "target is an Answer" do
    let(:target) { FactoryBot.create(:answer, user:) }

    include_examples "valid target type"
  end

  context "target is a Comment" do
    let(:target) { FactoryBot.create(:comment, user:, answer: FactoryBot.create(:answer, user:)) }

    include_examples "valid target type"
  end
end
