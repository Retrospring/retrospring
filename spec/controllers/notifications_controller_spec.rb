# frozen_string_literal: true

require "rails_helper"

describe NotificationsController do
  subject { get :index, params: { type: :new } }

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in(user)
  end

  context "user has no notifications" do
    it "should show an empty list" do
      subject
      expect(response).to render_template(:index)

      expect(controller.instance_variable_get(:@notifications)).to be_empty
    end
  end

  context "user has notifications" do
    let(:other_user) { FactoryBot.create(:user) }
    let(:another_user) { FactoryBot.create(:user) }
    let(:question) { FactoryBot.create(:question, user: user) }
    let!(:answer) { FactoryBot.create(:answer, question: question, user: other_user) }
    let!(:subscription) { Subscription.create(user: user, answer: answer) }
    let!(:comment) { FactoryBot.create(:comment, answer: answer, user: other_user) }

    it "should show a list of notifications" do
      subject
      expect(response).to render_template(:index)
      expect(controller.instance_variable_get(:@notifications)).to have_attributes(size: 2)
    end
  end
end
