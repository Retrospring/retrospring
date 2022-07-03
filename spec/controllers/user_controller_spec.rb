# frozen_string_literal: true

require "rails_helper"

describe UserController, type: :controller do
  let(:user) { FactoryBot.create :user,
                                 otp_module: :disabled,
                                 otp_secret_key: 'EJFNIJPYXXTCQSRTQY6AG7XQLAT2IDG5H7NGLJE3'}

  describe "#show" do
    subject { get :show, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show")
      end
    end
  end

  describe "#followers" do
    subject { get :followers, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show_follow template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end
    end
  end

  describe "#followings" do
    subject { get :followings, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show_follow template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end
    end
  end

  describe "#questions" do
    subject { get :questions, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/questions template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/questions")
      end
    end
  end
end
