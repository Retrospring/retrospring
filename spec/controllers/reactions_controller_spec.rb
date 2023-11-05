# frozen_string_literal: true

require "rails_helper"

describe ReactionsController, type: :controller do
  render_views

  describe "#index" do
    shared_examples_for "succeeds" do
      it "returns the correct response" do
        subject
        expect(response).to have_rendered :index
        expect(response).to have_http_status(200)
      end
    end

    subject { get :index, params: { username: answer_author.screen_name, id: answer.id } }

    let(:answer_author) { FactoryBot.create(:user) }
    let(:answer) { FactoryBot.create(:answer, user: answer_author) }
    let!(:reactees) { FactoryBot.create_list(:user, num_comments) }

    [0, 1, 5, 30].each do |num_comments|
      context "#{num_comments} reactions" do
        let(:num_comments) { num_comments }

        before do
          reactees.each { _1.smile(answer) }
        end

        include_examples "succeeds"
      end
    end
  end

  describe "#create" do
    let(:user) { FactoryBot.create(:user) }

    context "target type is Answer" do
      let(:params) do
        {
          username: user.screen_name,
          id:       answer_id,
          type:     "Answer",
        }.compact
      end
      let(:answer) { FactoryBot.create(:answer, user:) }

      subject { post(:create, params:, format: :turbo_stream) }

      context "when user is signed in" do
        before(:each) { sign_in(user) }

        context "when answer exists" do
          let(:answer_id) { answer.id }

          it "creates a reaction to the answer" do
            expect { subject }.to(change { Reaction.count }.by(1))
            expect(answer.reload.smiles.ids).to include(Reaction.last.id)
          end
        end

        context "when answer does not exist" do
          let(:answer_id) { "nein!" }

          it "does not create a reaction" do
            expect { subject }.not_to(change { Reaction.count })
          end
        end
      end

      context "when blocked by the answer's author" do
        let(:other_user) { FactoryBot.create(:user) }
        let(:answer) { FactoryBot.create(:answer, user: other_user) }
        let(:answer_id) { answer.id }

        before do
          other_user.block(user)
        end

        it "does not create a reaction" do
          expect { subject }.not_to(change { Reaction.count })
        end
      end

      context "when blocking the answer's author" do
        let(:other_user) { FactoryBot.create(:user) }
        let(:answer) { FactoryBot.create(:answer, user:) }
        let(:answer_id) { answer.id }

        before do
          user.block(other_user)
        end

        it "does not create a reaction" do
          expect { subject }.not_to(change { Reaction.count })
        end
      end
    end

    context "target type is Comment" do
      let(:params) do
        {
          username: user.screen_name,
          id:       comment_id,
          type:     "Comment",
        }.compact
      end
      let(:answer) { FactoryBot.create(:answer, user:) }
      let(:comment) { FactoryBot.create(:comment, user:, answer:) }

      subject { post(:create, params:, format: :turbo_stream) }

      context "when user is signed in" do
        before(:each) { sign_in(user) }

        context "when comment exists" do
          let(:comment_id) { comment.id }

          it "creates a smile to the comment" do
            expect { subject }.to(change { Reaction.count }.by(1))
            expect(comment.reload.smiles.ids).to include(Reaction.last.id)
          end
        end

        context "when comment does not exist" do
          let(:comment_id) { "nein!" }

          it "does not create a smile" do
            expect { subject }.not_to(change { Reaction.count })
          end
        end
      end
    end
  end

  describe "#destroy" do
    let(:user) { FactoryBot.create(:user) }

    context "target type is Answer" do
      let(:answer) { FactoryBot.create(:answer, user:) }
      let(:smile) { FactoryBot.create(:smile, user:, parent: answer) }
      let(:answer_id) { answer.id }

      let(:params) do
        {
          username: user.screen_name,
          id:       answer_id,
          type:     "Answer",
        }
      end

      subject { delete(:destroy, params:, format: :turbo_stream) }

      context "when user is signed in" do
        before(:each) { sign_in(user) }

        context "when the smile exists" do
          # ensure we already have it in the db
          before(:each) { smile }

          it "deletes the reaction" do
            expect { subject }.to(change { Reaction.count }.by(-1))
          end
        end

        context "when the reaction does not exist" do
          let(:answer_id) { "sonic_the_hedgehog" }

          include_examples "turbo does not succeed", "Record not found"
        end
      end
    end

    context "target type is Comment" do
      let(:answer) { FactoryBot.create(:answer, user:) }
      let(:comment) { FactoryBot.create(:comment, user:, answer:) }
      let(:comment_smile) { FactoryBot.create(:comment_smile, user:, parent: comment) }
      let(:comment_id) { comment.id }

      let(:params) do
        {
          username: user.screen_name,
          id:       comment_id,
          type:     "Comment",
        }
      end

      subject { delete(:destroy, params:, format: :turbo_stream) }

      context "when user is signed in" do
        before(:each) { sign_in(user) }

        context "when the reaction exists" do
          # ensure we already have it in the db
          before(:each) { comment_smile }

          it "deletes the reaction" do
            expect { subject }.to(change { Reaction.count }.by(-1))
          end
        end

        context "when the reaction does not exist" do
          let(:answer_id) { "sonic_the_hedgehog" }

          include_examples "turbo does not succeed", "Record not found"
        end
      end
    end
  end
end
