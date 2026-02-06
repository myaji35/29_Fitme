require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get dashboard" do
    @user = users(:one)
    sign_in @user
    get dashboard_url
    assert_response :success
  end
end
