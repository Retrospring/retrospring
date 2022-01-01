require 'rails_helper'

describe ServicesController, type: :controller do
  context 'successful Twitter sign in' do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in user
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
                                                                     'provider' => 'twitter',
                                                                     'uid' => '12',
                                                                     'info' => { 'nickname' => 'jack' },
                                                                     'credentials' => { 'token' => 'AAAA', 'secret' => 'BBBB' }
                                                                   })
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
    end

    after do
      OmniAuth.config.mock_auth[:twitter] = nil
    end

    subject { get :create, params: { provider: 'twitter' } }

    context 'no services connected' do
      it 'creates a service integration' do
        expect { subject }.to change { Service.count }.by(1)
      end
    end

    context 'a user has a service connected' do
      let(:other_user) { FactoryBot.create(:user) }
      let!(:service) { Services::Twitter.create(user: other_user, uid: 12) }

      it 'shows an error when trying to attach a service account which is already connected' do
        subject
        expect(flash[:error]).to eq("The Twitter account you are trying to connect is already connected to another #{APP_CONFIG['site_name']} account. If you are unable to disconnect the account yourself, please send us a Direct Message on Twitter: @retrospring.")
      end
    end
  end
end
