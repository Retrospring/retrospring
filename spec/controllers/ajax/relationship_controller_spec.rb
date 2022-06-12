# coding: utf-8
# frozen_string_literal: true

require "rails_helper"

describe Ajax::RelationshipController, type: :controller do
  shared_examples_for "params is empty" do
    let(:params) { {} }

    include_examples "ajax does not succeed", "is required"
  end

  let!(:user) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user) }

  describe "#create" do
    shared_examples_for "valid relationship type" do
      it_behaves_like "params is empty"

      context "screen_name does not exist" do
        let(:screen_name) { "peter-witzig" }

        include_examples "ajax does not succeed", "not found"
      end

      context "screen_name is current user" do
        let(:screen_name) { user.screen_name }

        include_examples "ajax does not succeed", "yourself"
      end

      context "screen_name is different from current_user" do
        let(:screen_name) { user2.screen_name }

        it "creates the relationship" do
          expect { subject }.to change { Relationship.count }.by(1)
          expect(Relationship.last.target.screen_name).to eq(screen_name)
        end
      end
    end

    let(:type)        { "Sauerkraut" }
    let(:screen_name) { user2.screen_name }
    let(:params)      { { type: type, screen_name: screen_name } }

    subject { post(:create, params: params) }

    it_behaves_like "requires login"

    context "user signed in" do
      before(:each) { sign_in(user) }

      context "type = 'follow'" do
        let(:type) { "follow" }

        include_examples "valid relationship type"
      end

      context "type = 'block'" do
        let(:type) { "block" }

        include_examples "valid relationship type"
      end

      context "type = 'dick'" do
        let(:type) { "dick" }

        it_behaves_like "params is empty"
        include_examples "ajax does not succeed", "Invalid parameter"
      end
    end
  end

  describe "#destroy" do
    shared_examples_for "valid relationship type" do
      let(:screen_name) { user2.screen_name }

      context "relationship exists" do
        before do
          user.public_send(type, user2)
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

      context "screen_name does not exist" do
        let(:screen_name) { "peter-witzig" }

        include_examples "ajax does not succeed", "not found"
      end
    end

    let(:type)        { "Sauerkraut" }
    let(:screen_name) { user2.screen_name }
    let(:params)      { { type: type, screen_name: screen_name } }

    subject { delete(:destroy, params: params) }

    it_behaves_like "requires login"

    context "user signed in" do
      before(:each) { sign_in(user) }

      context "type = 'follow'" do
        let(:type) { "follow" }

        include_examples "valid relationship type"
      end

      context "type = 'block'" do
        let(:type) { "block" }

        include_examples "valid relationship type"
      end

      context "type = 'dick'" do
        let(:type) { "dick" }

        include_examples "ajax does not succeed", "Invalid parameter"
      end
    end
  end
end
