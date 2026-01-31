require "test_helper"

class PartnersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @regular_user = users(:regular_user)
    @partner = partners(:active_partner)
  end

  # Index tests
  test "admin should get partners index" do
    sign_in @admin
    get partners_url
    assert_response :success
    assert_select "h1", "파트너 목록"
  end

  test "regular user should not access partners index" do
    sign_in @regular_user
    get partners_url
    assert_redirected_to root_path
    assert_equal "접근 권한이 없습니다.", flash[:alert]
  end

  test "guest should not access partners index" do
    get partners_url
    assert_redirected_to new_user_session_path
  end

  # Show tests
  test "admin should show partner" do
    sign_in @admin
    get partner_url(@partner)
    assert_response :success
    assert_select "h2", @partner.company_name
  end

  # New tests
  test "should get new partner form" do
    get new_partner_url
    assert_response :success
    assert_select "h1", "파트너 계정 신청"
  end

  # Create tests
  test "should create partner with valid data" do
    assert_difference("Partner.count", 1) do
      post partners_url, params: {
        partner: {
          name: "홍길동",
          company_name: "테스트 회사",
          contact_email: "test@example.com",
          website_url: "https://test.com"
        }
      }
    end

    partner = Partner.last
    assert_redirected_to partner_path(partner)
    assert_equal "trial", partner.subscription_status
    assert_not_nil partner.api_key
    assert partner.api_key.start_with?("fitme_")
  end

  test "should not create partner with invalid email" do
    assert_no_difference("Partner.count") do
      post partners_url, params: {
        partner: {
          name: "홍길동",
          company_name: "테스트 회사",
          contact_email: "invalid-email"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Dashboard tests
  test "admin should access partner dashboard" do
    sign_in @admin
    get dashboard_partner_url(@partner)
    assert_response :success
    assert_select ".partner-dashboard"
    assert_select "code", text: /fitme_/
  end

  test "regular user should not access partner dashboard" do
    sign_in @regular_user
    get dashboard_partner_url(@partner)
    assert_redirected_to root_path
  end

  # Subscription management tests
  test "admin should renew partner subscription" do
    sign_in @admin
    old_ends_at = @partner.subscription_ends_at

    post renew_subscription_partner_url(@partner)

    @partner.reload
    assert @partner.subscription_ends_at > old_ends_at
    assert_equal "active", @partner.subscription_status
    assert_redirected_to edit_partner_path(@partner)
  end

  test "admin should suspend partner subscription" do
    sign_in @admin

    post suspend_subscription_partner_url(@partner)

    @partner.reload
    assert_equal "suspended", @partner.subscription_status
    assert_redirected_to edit_partner_path(@partner)
  end

  test "regular user cannot renew subscription" do
    sign_in @regular_user

    post renew_subscription_partner_url(@partner)

    assert_redirected_to root_path
    assert_equal "접근 권한이 없습니다.", flash[:alert]
  end
end
