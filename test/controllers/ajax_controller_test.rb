require 'test_helper'

class AjaxControllerTest < ActionController::TestCase
  test "should get ask" do
    get :ask
    assert_response :success
  end

end
