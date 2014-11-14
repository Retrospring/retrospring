require 'rails_helper'

RSpec.describe UserController, :type => :request do
  before do
    # we need at least 2 users to test meaningfully
    @user1 = create(:user)
    @user2 = create(:user)
  end

  it 'shows the user page' do
    get "/@#{@user1.screen_name}"
    assert_select "h3.text-muted", :text => @user1.screen_name
  end
end
