# frozen_string_literal: true

require "rails_helper"

describe CommentsController, type: :controller do
  describe "#index" do
    shared_examples_for "succeeds" do
      it "returns the correct response" do
        subject
        expect(response).to have_rendered("comment/index")
        expect(response).to have_http_status(200)
        expect(assigns(:comments)).to eq(comments)
        expect(assigns(:comments)).to_not include(unrelated_comment)
      end
    end

    subject { get :index, params: { username: answer_author.screen_name, id: answer.id } }

    let(:answer_author) { FactoryBot.create(:user) }
    let(:answer) { FactoryBot.create(:answer, user: answer_author) }
    let(:commenter) { FactoryBot.create(:user) }
    let!(:comments) { FactoryBot.create_list(:comment, num_comments, answer:, user: commenter) }
    let!(:unrelated_comment) do
      FactoryBot.create(:comment,
                        answer: FactoryBot.create(:answer, user: FactoryBot.create(:user)),
                        user:   commenter,)
    end

    [0, 1, 5, 30].each do |num_comments|
      context "#{num_comments} comments" do
        let(:num_comments) { num_comments }

        include_examples "succeeds"
      end
    end
  end

  describe "#show_reactions" do
    let(:answer_author) { FactoryBot.create(:user) }
    let(:answer) { FactoryBot.create(:answer, user: answer_author) }
    let(:commenter) { FactoryBot.create(:user) }
    let(:comment) { FactoryBot.create(:comment, answer:, user: commenter) }

    context "a regular web navigation request" do
      subject { get :show_reactions, params: { username: commenter.screen_name, id: comment.id } }

      it "should redirect to the answer page" do
        subject

        expect(response).to redirect_to answer_path(username: answer_author.screen_name, id: answer.id)
      end
    end

    context "a Turbo Frame request" do
      subject { get :show_reactions, params: { username: commenter.screen_name, id: comment.id } }

      it "renders the show_reaction template" do
        @request.headers["Turbo-Frame"] = "some_id"

        subject

        expect(response).to render_template(:show_reactions)
      end
    end
  end
end
