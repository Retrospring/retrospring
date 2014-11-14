require 'rails_helper'

RSpec.describe UserController, :type => :controller do
  before do
    @user = create(:user)
  end

  it 'responds successfully with a HTTP 200 status code' do
    get :show, username: @user.screen_name, page: 1
    expect(response).to be_success
    expect(response).to have_http_status(200)
  end
end
