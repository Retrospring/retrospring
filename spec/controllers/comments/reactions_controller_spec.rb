# frozen_string_literal: true

require "rails_helper"

describe Comments::ReactionsController, type: :controller do
  describe "#show" do
    let(:answer_author) { FactoryBot.create(:user) }
    let(:answer) { FactoryBot.create(:answer, user: answer_author) }
    let(:commenter) { FactoryBot.create(:user) }
    let(:comment) { FactoryBot.create(:comment, answer:, user: commenter) }

    context "a regular web navigation request" do
      subject { get :show, params: { username: commenter.screen_name, id: comment.id } }

      it "should redirect to the answer page" do
        subject

        expect(response).to redirect_to answer_path(username: answer_author.screen_name, id: answer.id)
      end
    end

    context "a Turbo Frame request" do
      subject { get :show, params: { username: commenter.screen_name, id: comment.id } }

      it "renders the show_reaction template" do
        @request.headers["Turbo-Frame"] = "some_id"

        subject

        expect(response).to render_template(:show)
      end
    end
  end
end
