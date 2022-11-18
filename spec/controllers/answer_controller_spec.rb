# frozen_string_literal: true

require "rails_helper"

describe AnswerController do
  let(:user) do
    FactoryBot.create :user,
                      otp_module:     :disabled,
                      otp_secret_key: "AAAAAAAA"
  end
  let(:answer) { FactoryBot.create :answer, user: }

  describe "#show" do
    subject { get :show, params: { username: user.screen_name, id: answer.id } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the answer/show template" do
        subject
        expect(assigns(:answer)).to eq(answer)
        expect(response).to render_template("answer/show")
      end
    end

    context "user opts out of search indexing" do
      render_views

      before(:each) do
        sign_in user
        user.privacy_noindex = true
        user.save
      end

      it "renders the answer/show template" do
        subject
        expect(assigns(:answer)).to eq(answer)
        expect(response.body).to include("<meta content='noindex' name='robots'>")
      end
    end
  end
end
