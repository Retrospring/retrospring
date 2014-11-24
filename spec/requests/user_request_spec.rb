require 'rails_helper'

RSpec.describe "user page", :type => :request do
  before do
    @user = create(:user)
  end

  it 'shows the user page' do
    get "/@#{@user.screen_name}"
    assert_select "h3.text-muted", :text => @user.screen_name
  end
end
