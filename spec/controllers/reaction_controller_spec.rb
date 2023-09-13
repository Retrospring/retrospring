# frozen_string_literal: true

require "rails_helper"

describe ReactionController, type: :controller do
  describe "#index" do
    shared_examples_for "succeeds" do
      it "returns the correct response" do
        subject
        expect(response).to have_rendered("reaction/index")
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
end
