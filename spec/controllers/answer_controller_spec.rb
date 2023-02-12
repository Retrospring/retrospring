# frozen_string_literal: true

require "rails_helper"

describe AnswerController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

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

  describe "#pin" do
    subject { post :pin, params: { username: user.screen_name, id: answer.id }, format: :turbo_stream }

    context "user signed in" do
      before(:each) { sign_in user }

      it "pins the answer" do
        travel_to(Time.at(1603290950).utc) do
          expect { subject }.to change { answer.reload.pinned_at }.from(nil).to(Time.at(1603290950).utc)
          expect(response.body).to include("turbo-stream action=\"update\" target=\"ab-pin-#{answer.id}\"")
        end
      end
    end

    context "other user signed in" do
      let(:other_user) { FactoryBot.create(:user) }

      before(:each) { sign_in other_user }

      it "does not pin the answer" do
        travel_to(Time.at(1603290950).utc) do
          expect { subject }.not_to(change { answer.reload.pinned_at })
        end
      end
    end
  end

  describe "#unpin" do
    subject { delete :unpin, params: { username: user.screen_name, id: answer.id }, format: :turbo_stream }

    context "user signed in" do
      before(:each) do
        sign_in user
        answer.update!(pinned_at: Time.at(1603290950).utc)
      end

      it "unpins the answer" do
        expect { subject }.to change { answer.reload.pinned_at }.from(Time.at(1603290950).utc).to(nil)
        expect(response.body).to include("turbo-stream action=\"update\" target=\"ab-pin-#{answer.id}\"")
      end
    end

    context "other user signed in" do
      let(:other_user) { FactoryBot.create(:user) }

      before(:each) do
        sign_in other_user
        answer.update!(pinned_at: Time.at(1603290950).utc)
      end

      it "does not unpin the answer" do
        expect { subject }.not_to(change { answer.reload.pinned_at })
      end
    end
  end
end
