require 'rails_helper'

RSpec.describe "user page", :type => :request do
  before do
    @user = create(:user)
  end

  it 'shows the user page' do
    get "/@#{@user.screen_name}"
    assert_select ".user-username", :text => @user.screen_name
  end
end
