require "test_helper"

class AdminFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin manages partners: view list -> renew subscription -> suspend subscription" do
    admin = users(:admin)
    sign_in admin

    # Step 1: View partners list
    get partners_path
    assert_response :success
    assert_select ".partners-table"

    # Step 2: View partner details
    partner = partners(:trial_partner)
    get partner_path(partner)
    assert_response :success
    assert_select "h2", partner.company_name

    # Step 3: Access partner dashboard
    get dashboard_partner_path(partner)
    assert_response :success
    assert_select ".partner-dashboard"
    assert_select "code", text: /fitme_/

    # Step 4: Renew partner subscription
    old_ends_at = partner.subscription_ends_at
    old_status = partner.subscription_status

    post renew_subscription_partner_path(partner)

    assert_redirected_to edit_partner_path(partner)
    assert_equal "구독이 1개월 연장되었습니다.", flash[:notice]

    partner.reload
    assert partner.subscription_ends_at > old_ends_at
    assert_equal "active", partner.subscription_status
    assert_not_nil partner.last_billed_at

    # Step 5: Suspend partner subscription
    post suspend_subscription_partner_path(partner)

    assert_redirected_to edit_partner_path(partner)
    assert_equal "구독이 일시정지되었습니다.", flash[:notice]

    partner.reload
    assert_equal "suspended", partner.subscription_status
    assert_not partner.subscription_active?

    sign_out admin
  end

  test "admin has full access to all features" do
    admin = users(:admin)
    sign_in admin

    # Can access partners index
    get partners_path
    assert_response :success

    # Can create new partner
    get new_partner_path
    assert_response :success

    # Can edit partner
    partner = partners(:active_partner)
    get edit_partner_path(partner)
    assert_response :success

    # Can view dashboard
    get dashboard_path
    assert_response :success

    sign_out admin
  end

  test "admin can view API usage statistics" do
    admin = users(:admin)
    partner = partners(:active_partner)
    sign_in admin

    get dashboard_partner_path(partner)
    assert_response :success

    # Should show API usage stats
    assert_select ".api-count"
    assert_select "table.usage-table"

    sign_out admin
  end
end
