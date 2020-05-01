# coding: utf-8
# frozen_string_literal: true

require "rails_helper"

describe Ajax::CommentController, :ajax_controller, type: :controller do
  let(:answer) { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }

  describe "#create" do
    let(:params) do
      {
        answer: answer_id,
        comment: comment
      }.compact
    end

    subject { post(:create, params: params) }

    context "when user is signed in" do
      shared_examples "creates the comment" do
        it "creates a comment to the answer" do
          expect { subject }.to(change { Comment.count }.by(1))
          expect(answer.reload.comments.ids).to include(Comment.last.id)
        end

        include_examples "returns the expected response"
      end

      shared_examples "does not create the comment" do
        it "does not create a comment" do
          expect { subject }.not_to(change { Comment.count })
        end

        include_examples "returns the expected response"
      end

      before(:each) { sign_in(user) }

      context "when all parameters are given" do
        let(:comment) { "// Here be dragons." }

        context "when answer exists" do
          let(:answer_id) { answer.id }

          let(:expected_response) do
            {
              "success" => true,
              "status" => "okay",
              "message" => anything,
              "render" => anything,
              "count" => 1
            }
          end

          include_examples "creates the comment"

          context "when comment is too long" do
            let(:comment) { "E" * 621 }
            let(:expected_response) do
              {
                "success" => false,
                "status" => "rec_inv",
                "message" => anything
              }
            end

            include_examples "does not create the comment"
          end
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

          include_examples "does not create the comment"
        end
      end

      context "when some parameters are missing" do
        let(:answer_id) { nil }
        let(:comment) { "" }

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
      let(:comment) { "HACKED" }

      let(:expected_response) do
        {
          "success" => false,
          "status" => "err",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#destroy" do
    let(:answer_user) { FactoryBot.create(:user) }
    let(:answer) { FactoryBot.create(:answer, user: answer_user) }
    let(:comment_user) { user }
    let(:comment) { FactoryBot.create(:comment, user: comment_user, answer: answer) }
    let(:comment_id) { comment.id }

    let(:params) do
      {
        comment: comment_id
      }
    end

    subject { delete(:destroy, params: params) }

    context "when user is signed in" do
      shared_examples "deletes the comment" do
        let(:expected_response) do
          {
            "success" => true,
            "status" => "okay",
            "message" => anything,
            "count" => 0
          }
        end

        it "deletes the comment" do
          comment # ensure we already have it in the db
          expect { subject }.to(change { Comment.count }.by(-1))
        end

        include_examples "returns the expected response"
      end

      shared_examples "does not delete the comment" do
        let(:expected_response) do
          {
            "success" => false,
            "status" => "nopriv",
            "message" => anything
          }
        end

        it "does not delete the comment" do
          comment # ensure we already have it in the db
          expect { subject }.not_to(change { Comment.count })
        end

        include_examples "returns the expected response"
      end

      before(:each) { sign_in(user) }

      context "when the comment exists and was made by the current user" do
        include_examples "deletes the comment"
      end

      context "when the comment exists and was not made by the current user" do
        let(:comment_user) { FactoryBot.create(:user) }

        include_examples "does not delete the comment"

        context "when the current user created the answer" do
          let(:answer_user) { user }

          include_examples "deletes the comment"
        end

        %i[moderator administrator].each do |privileged_role|
          context "when the current user is a #{privileged_role}" do
            around do |example|
              user.add_role privileged_role
              example.run
              user.remove_role privileged_role
            end

            include_examples "deletes the comment"
          end
        end
      end

      context "when the comment does not exist" do
        let(:comment_id) { "sonic_the_hedgehog" }

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
          "status" => "nopriv",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end
end
