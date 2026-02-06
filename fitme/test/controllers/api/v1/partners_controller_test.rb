require "test_helper"

class Api::V1::PartnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @partner = partners(:one)
  end

  test "should get index" do
    get api_v1_partners_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_partner_url(@partner)
    assert_response :success
  end

  test "should create partner" do
    assert_difference("Partner.count", 1) do
      post api_v1_partners_url, params: {
        partner: {
          name: "New Partner",
          company_name: "New Company",
          contact_email: "new@test.com",
          monthly_fee: 50.0
        }
      }
    end
    assert_response :created
  end
end
