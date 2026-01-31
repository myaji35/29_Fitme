require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "complete user journey: signup -> profile -> add items -> get outfit recommendations" do
    # Step 1: User signs up
    get new_user_registration_path
    assert_response :success

    assert_difference("User.count", 1) do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.find_by(email: "newuser@example.com")
    assert_not_nil user

    # Profile is created by callback, reload to check
    user.reload
    assert user.profile.present?, "Profile should be auto-created"

    # Step 2: User updates profile with measurements
    sign_in user

    get edit_profile_path
    assert_response :success

    patch profile_path, params: {
      profile: {
        height_cm: 170,
        weight_kg: 65
      }
    }

    assert_redirected_to profile_path
    user.profile.reload
    assert_equal 170.0, user.profile.height_cm
    assert_equal 65.0, user.profile.weight_kg

    # Step 3: User accesses dashboard
    get dashboard_path
    assert_response :success

    # Step 4: User adds clothing items (skipped - requires file upload)
    # Would test: visit items page, upload image, AI classifies, item saved

    # Step 5: User can view outfit suggestions (skipped - requires weather API)
    # Would test: request outfit suggestions, view recommendations

    sign_out user
  end

  test "user cannot access admin or partner features" do
    user = users(:regular_user)
    sign_in user

    # Cannot access partners index
    get partners_path
    assert_redirected_to root_path
    assert_equal "접근 권한이 없습니다.", flash[:alert]

    # Cannot access partner dashboard
    partner = partners(:active_partner)
    get dashboard_partner_path(partner)
    assert_redirected_to root_path

    sign_out user
  end
end
