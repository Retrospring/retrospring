# coding: utf-8
# frozen_string_literal: true

require "rails_helper"

describe Ajax::SmileController, :ajax_controller, type: :controller do
  describe "#create" do
    let(:params) do
      {
        id: answer_id
      }.compact
    end
    let(:answer) { FactoryBot.create(:answer, user: user) }

    subject { post(:create, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when answer exists" do
        let(:answer_id) { answer.id }
        let(:expected_response) do
          {
            "success" => true,
            "status" => "okay",
            "message" => anything
          }
        end

        it "creates a smile to the answer" do
          expect { subject }.to(change { Appendable::Reaction.count }.by(1))
          expect(answer.reload.smiles.ids).to include(Appendable::Reaction.last.id)
        end

        include_examples "returns the expected response"
      end

      context "when answer does not exist" do
        let(:answer_id) { "nein!" }

        let(:expected_response) do
          {
            "success" => false,
            "status" => anything,
            "message" => anything
          }
        end

        it "does not create a smile" do
          expect { subject }.not_to(change { Appendable::Reaction.count })
        end

        include_examples "returns the expected response"
      end

      context "when some parameters are missing" do
        let(:answer_id) { nil }

        let(:expected_response) do
          {
            "success" => false,
            "status" => "parameter_error",
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:answer_id) { answer.id }

      let(:expected_response) do
        {
          "success" => false,
          "status" => "fail",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end

    context "when blocked by the answer's author" do
      let(:other_user) { FactoryBot.create(:user) }
      let(:answer) { FactoryBot.create(:answer, user: other_user) }
      let(:answer_id) { answer.id }

      before do
        other_user.block(user)
      end

      let(:expected_response) do
        {
          "success" => false,
          "status"  => "fail",
          "message" => anything
        }
      end

      it "does not create a smile" do
        expect { subject }.not_to(change { Appendable::Reaction.count })
      end

      include_examples "returns the expected response"
    end

    context "when blocking the answer's author" do
      let(:other_user) { FactoryBot.create(:user) }
      let(:answer) { FactoryBot.create(:answer, user: user) }
      let(:answer_id) { answer.id }

      before do
        user.block(other_user)
      end

      let(:expected_response) do
        {
          "success" => false,
          "status"  => "fail",
          "message" => anything
        }
      end

      it "does not create a smile" do
        expect { subject }.not_to(change { Appendable::Reaction.count })
      end

      include_examples "returns the expected response"
    end
  end

  describe "#destroy" do
    let(:answer) { FactoryBot.create(:answer, user: user) }
    let(:smile) { FactoryBot.create(:smile, user: user, parent: answer) }
    let(:answer_id) { answer.id }

    let(:params) do
      {
        id: answer_id
      }
    end

    subject { delete(:destroy, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when the smile exists" do
        # ensure we already have it in the db
        before(:each) { smile }

        let(:expected_response) do
          {
            "success" => true,
            "status" => "okay",
            "message" => anything
          }
        end

        it "deletes the smile" do
          expect { subject }.to(change { Appendable::Reaction.count }.by(-1))
        end

        include_examples "returns the expected response"
      end

      context "when the smile does not exist" do
        let(:answer_id) { "sonic_the_hedgehog" }

        let(:expected_response) do
          {
            "success" => false,
            "status" => anything,
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:expected_response) do
        {
          "success" => false,
          "status" => "fail",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#create_comment" do
    let(:params) do
      {
        id: comment_id
      }.compact
    end
    let(:answer) { FactoryBot.create(:answer, user: user) }
    let(:comment) { FactoryBot.create(:comment, user: user, answer: answer) }

    subject { post(:create_comment, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when comment exists" do
        let(:comment_id) { comment.id }
        let(:expected_response) do
          {
            "success" => true,
            "status" => "okay",
            "message" => anything
          }
        end

        it "creates a smile to the comment" do
          expect { subject }.to(change { Appendable::Reaction.count }.by(1))
          expect(comment.reload.smiles.ids).to include(Appendable::Reaction.last.id)
        end

        include_examples "returns the expected response"
      end

      context "when comment does not exist" do
        let(:comment_id) { "nein!" }

        let(:expected_response) do
          {
            "success" => false,
            "status" => anything,
            "message" => anything
          }
        end

        it "does not create a smile" do
          expect { subject }.not_to(change { Appendable::Reaction.count })
        end

        include_examples "returns the expected response"
      end

      context "when some parameters are missing" do
        let(:comment_id) { nil }

        let(:expected_response) do
          {
            "success" => false,
            "status" => "parameter_error",
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:comment_id) { comment.id }

      let(:expected_response) do
        {
          "success" => false,
          "status" => "fail",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#destroy_comment" do
    let(:answer) { FactoryBot.create(:answer, user: user) }
    let(:comment) { FactoryBot.create(:comment, user: user, answer: answer) }
    let(:comment_smile) { FactoryBot.create(:comment_smile, user: user, parent: comment) }
    let(:comment_id) { comment.id }

    let(:params) do
      {
        id: comment_id
      }
    end

    subject { delete(:destroy_comment, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when the smile exists" do
        # ensure we already have it in the db
        before(:each) { comment_smile }

        let(:expected_response) do
          {
            "success" => true,
            "status" => "okay",
            "message" => anything
          }
        end

        it "deletes the smile" do
          expect { subject }.to(change { Appendable::Reaction.count }.by(-1))
        end

        include_examples "returns the expected response"
      end

      context "when the smile does not exist" do
        let(:answer_id) { "sonic_the_hedgehog" }

        let(:expected_response) do
          {
            "success" => false,
            "status" => anything,
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:expected_response) do
        {
          "success" => false,
          "status" => "fail",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end
end
