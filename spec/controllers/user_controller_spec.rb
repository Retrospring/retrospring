# frozen_string_literal: true

require "rails_helper"

describe UserController, type: :controller do
  let(:user) do
    FactoryBot.create :user,
                      otp_module:     :disabled,
                      otp_secret_key: "EJFNIJPYXXTCQSRTQY6AG7XQLAT2IDG5H7NGLJE3"
  end

  shared_examples_for "social graph hidden" do
    context "user has social graph hidden" do
      before(:each) do
        user.update(privacy_hide_social_graph: true)
      end

      it "shows the followers template to the current user" do
        sign_in user
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end

      it "redirects to the user profile page if not logged in" do
        subject
        expect(response).to redirect_to(user_path(user))
      end

      it "redirects to the user profile page if logged in as a different user" do
        sign_in FactoryBot.create(:user)
        subject
        expect(response).to redirect_to(user_path(user))
      end
    end
  end

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

    context "user opts out of search indexing" do
      render_views

      before(:each) do
        sign_in user
        user.privacy_noindex = true
        user.save
      end

      it "renders the answer/show template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response.body).to include("<meta content='noindex' name='robots'>")
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

    include_examples "social graph hidden"
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

    include_examples "social graph hidden"
  end

  describe "#questions" do
    let!(:question) { FactoryBot.create(:question, user:, direct: true, author_is_anonymous: false) }
    subject { get :questions, params: { username: user.screen_name } }

    it "renders the user/questions template" do
      subject
      expect(assigns(:user)).to eq(user)
      expect(response).to render_template("user/questions")
    end

    context "when the current user is the question author" do
      before do
        sign_in user
      end

      it "renders all questions" do
        subject
        expect(assigns(:questions).size).to eq(1)
      end
    end

    context "when the current user is someone else" do
      let(:another_user) { FactoryBot.create :user }

      before do
        sign_in another_user
      end

      it "renders no questions" do
        subject
        expect(assigns(:questions).size).to eq(0)
      end
    end

    context "when a moderator uses unmask" do
      let(:another_user) { FactoryBot.create :user, roles: ["moderator"] }

      before do
        sign_in another_user
        allow_any_instance_of(UserHelper).to receive(:moderation_view?) { true }
      end

      it "contains all questions" do
        subject
        expect(assigns(:questions).size).to eq(1)
      end
    end

    context "when user is not signed in" do
      it "contains no questions" do
        subject
        expect(assigns(:questions).size).to eq(0)
      end
    end
  end
end
