require 'rails_helper'

describe AnswerController do
  let(:user) { FactoryBot.create :user,
                                 otp_module: :disabled,
                                 otp_secret_key: 'AAAAAAAA'}
  let(:answer) { FactoryBot.create :answer, user: user }

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

      before(:each) {
        sign_in user
        user.privacy_noindex = true
        user.save
      }

      it "renders the answer/show template" do
        subject
        expect(assigns(:answer)).to eq(answer)
        expect(response.body).to include("<meta content='noindex' name='robots'>")
      end
    end
  end
end
