# frozen_string_literal: true

require "rails_helper"

require "use_case/relationship/create"
require "errors"

describe UseCase::Relationship::Create do
  shared_examples_for "valid relationship type" do
    context "source_user does not exist" do
      let(:source_user) { "Schweinsbraten" }

      include_examples "raises an error", Errors::UserNotFound
    end

    context "target_user does not exist" do
      let(:target_user)  { "peterwitzig" }

      include_examples "raises an error", Errors::UserNotFound
    end

    context "target_user is source_user" do
      let(:target_user)  { user1.screen_name }

      include_examples "raises an error", Errors::SelfAction
    end

    context "target_user is different from source_user" do
      its([:status]) { is_expected.to eq(201) }
      its([:extra])  { is_expected.to eq(target_user: user2) }

      it "creates a relationship" do
        expect { subject }.to change { Relationship.count }.by(1)
        last_relationship = Relationship.last
        expect(last_relationship.source_id).to eq(user1.id)
        expect(last_relationship.target_id).to eq(user2.id)
      end
    end
  end

  let(:base_params) do
    {
      source_user: source_user,
      target_user: target_user,
      type:        type
    }
  end
  let(:params)      { base_params }
  let(:source_user) { user1 }
  let(:target_user) { user2 }
  let(:type)        { nil }

  # test data:
  let!(:user1) { FactoryBot.create(:user, screen_name: "timallen") }
  let!(:user2) { FactoryBot.create(:user, screen_name: "joehilyar") }

  subject { described_class.call(params) }

  context "type = 'follow'" do
    let(:type) { "follow" }

    include_examples "valid relationship type"

    context "using screen names" do
      let(:source_user) { user1.screen_name }
      let(:target_user) { user2.screen_name }

      include_examples "valid relationship type"
    end
  end

  context "type = 'dick'" do
    let(:type) { "dick" }

    include_examples "raises an error", Dry::Types::ConstraintError
  end
end
