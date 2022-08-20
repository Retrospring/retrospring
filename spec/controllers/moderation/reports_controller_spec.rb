# frozen_string_literal: true

require "rails_helper"

describe Moderation::ReportsController, type: :controller do
  let(:user) { FactoryBot.create :user, roles: ["moderator"] }

  describe "#index" do
    subject { get :index }

    before do
      sign_in user
    end

    it "renders the user/questions template" do
      subject
      expect(response).to render_template("moderation/reports/index")
    end
  end
end
