# frozen_string_literal: true

require "rails_helper"

require "use_case/relationship/destroy"
require "errors"

describe UseCase::Relationship::Destroy do
  shared_examples_for "valid relationship type" do
    its([:status]) { is_expected.to eq(204) }
    its([:extra])  { is_expected.to eq(target_user: user2) }

    context "relationship exists" do
      before do
        user1.public_send(type, user2)
      end

      it "destroys a relationship" do
        expect { subject }.to change { Relationship.count }.by(-1)
      end
    end

    context "relationship does not exist" do
      it "does not change anything at all" do
        expect { subject }.to change { Relationship.count }.by(0)
      end
    end

    context "current_user does not exist" do
      let(:current_user) { "Schweinsbraten" }
      let(:target_user) { user2.screen_name }

      include_examples "raises an error", Errors::UserNotFound
    end

    context "target_user does not exist" do
      let(:current_user) { user1.screen_name }
      let(:target_user) { "peterwitzig" }

      include_examples "raises an error", Errors::UserNotFound
    end
  end

  let(:base_params) do
    {
      current_user: current_user,
      target_user:  target_user,
      type:         type
    }
  end
  let(:params)          { base_params }
  let(:current_user)    { user1.screen_name }
  let(:target_user)     { user2.screen_name }
  let(:type)            { nil }

  # test data:
  let!(:user1) { FactoryBot.create(:user, screen_name: "timallen") }
  let!(:user2) { FactoryBot.create(:user, screen_name: "joehilyar") }

  subject { described_class.call(params) }

  context "type = 'follow'" do
    let(:type) { "follow" }

    include_examples "valid relationship type"
  end

  context "type = 'dick'" do
    let(:type) { "dick" }

    include_examples "raises an error", Dry::Types::ConstraintError
  end
end
