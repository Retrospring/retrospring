# frozen_string_literal: true

require "rails_helper"

describe Moderation::QuestionsController, type: :controller do
  let(:user) { FactoryBot.create :user, roles: ["moderator"] }

  describe "#index" do
    subject { get :index, params: }

    let(:params) { { author_identifier: "test" } }

    before do
      sign_in user
    end

    it "renders the moderation/questions/index template" do
      subject
      expect(response).to render_template("moderation/questions/index")
    end
  end
end
