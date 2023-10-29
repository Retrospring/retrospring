# frozen_string_literal: true

require "rails_helper"

describe UseCase::Reaction::Create do
  shared_examples_for "valid target type" do
    it "creates a reaction" do
      expect { subject }.to change { target.reload.smile_count }.by(1)
    end
  end

  subject { UseCase::Reaction::Create.call(source_user: user, target:) }

  let(:user) { FactoryBot.create(:user) }

  context "target is an Answer" do
    let(:target) { FactoryBot.create(:answer, user:) }

    include_examples "valid target type"
  end

  context "target is a Comment" do
    let(:target) { FactoryBot.create(:comment, user:, answer: FactoryBot.create(:answer, user:)) }

    include_examples "valid target type"
  end

  context "target is a Question" do
    let(:target) { FactoryBot.create(:question) }

    include_examples "raises an error", Dry::Types::ConstraintError
  end
end
