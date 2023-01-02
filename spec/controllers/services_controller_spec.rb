# frozen_string_literal: true

require "rails_helper"

describe ServicesController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "renders the services settings page with no services" do
        subject
        expect(response).to render_template("index")
        expect(controller.instance_variable_get(:@services)).to be_empty
      end

      context "user has a service token expired notification" do
        let(:notification) do
          Notification::ServiceTokenExpired.create(
            target_id:    user.id,
            target_type:  "User::ExpiredTwitterServiceConnection",
            recipient_id: user.id,
            new:          true
          )
        end

        it "marks the notification as read" do
          expect { subject }.to change { notification.reload.new }.from(true).to(false)
        end
      end

      context "user has Twitter connected" do
        before do
          Services::Twitter.create(user:, uid: 12)
        end

        it "renders the services settings page" do
          subject
          expect(response).to render_template("index")
          expect(controller.instance_variable_get(:@services)).not_to be_empty
        end
      end
    end
  end

  describe "#create" do
    subject { get :create, params: { provider: "twitter" } }

    context "successful Twitter sign in" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
                                                                       "provider"    => "twitter",
                                                                       "uid"         => "12",
                                                                       "info"        => { "nickname" => "jack" },
                                                                       "credentials" => { "token" => "AAAA", "secret" => "BBBB" }
                                                                     })
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      end

      after do
        OmniAuth.config.mock_auth[:twitter] = nil
      end

      context "no services connected" do
        it "creates a service integration" do
          expect { subject }.to change { Service.count }.by(1)
        end
      end

      context "a user has a service connected" do
        let(:other_user) { FactoryBot.create(:user) }
        let!(:service) { Services::Twitter.create(user: other_user, uid: 12) }

        it "shows an error when trying to attach a service account which is already connected" do
          subject
          expect(flash[:error]).to eq("The Twitter account you are trying to connect is already connected to another #{APP_CONFIG['site_name']} account. If you are unable to disconnect the account yourself, please send us a Direct Message on Twitter: @retrospring.")
        end
      end
    end
  end

  describe "#update" do
    subject { patch :update, params: }

    context "not signed in" do
      let(:params) { { id: 1 } }

      it "redirects to sign in page" do
        subject
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user with Twitter connection" do
      before { sign_in user }

      let(:user) { FactoryBot.create(:user) }
      let(:service) { Services::Twitter.create(user:, uid: 12) }
      let(:params) { { id: service.id, service: { post_tag: } } }

      context "tag is valid" do
        let(:post_tag) { "#askaraccoon" }

        it "updates a service connection" do
          expect { subject }.to change { service.reload.post_tag }.to("#askaraccoon")
          expect(response).to redirect_to(services_path)
          expect(flash[:success]).to eq("Service updated successfully.")
        end
      end

      context "tag is too long" do
        let(:post_tag) { "a" * 21 }  # 1 character over the limit

        it "shows an error" do
          subject
          expect(response).to redirect_to(services_path)
          expect(flash[:error]).to eq("Unable to update service.")
        end
      end
    end
  end
end
