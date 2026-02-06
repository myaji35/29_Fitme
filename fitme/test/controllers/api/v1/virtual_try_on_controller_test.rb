require "test_helper"

class Api::V1::VirtualTryOnControllerTest < ActionDispatch::IntegrationTest
  setup do
    @active_partner = partners(:active_partner)
    @trial_partner = partners(:trial_partner)
    @suspended_partner = partners(:suspended_partner)
    @public_profile = profiles(:user_profile)
    @private_profile = profiles(:admin_profile)
  end

  # Authentication tests
  test "should reject request without API key" do
    post api_v1_virtual_try_on_url, params: {
      avatar_id: @public_profile.secure_id,
      clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
    }

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "API key missing", json_response["error"]
  end

  test "should reject request with invalid API key" do
    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer invalid_key" },
      params: {
        avatar_id: @public_profile.secure_id,
        clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
      }

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Invalid API key", json_response["error"]
  end

  test "should reject request with suspended partner" do
    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer #{@suspended_partner.api_key}" },
      params: {
        avatar_id: @public_profile.secure_id,
        clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
      }

    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Subscription expired or suspended", json_response["error"]
  end

  # Parameter validation tests
  test "should require avatar_id parameter" do
    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer #{@active_partner.api_key}" },
      params: {
        clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
      }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "avatar_id and clothing_image are required", json_response["error"]
  end

  test "should require clothing_image parameter" do
    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer #{@active_partner.api_key}" },
      params: {
        avatar_id: @public_profile.secure_id
      }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "avatar_id and clothing_image are required", json_response["error"]
  end

  # Privacy tests
  test "should reject private avatar" do
    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer #{@active_partner.api_key}" },
      params: {
        avatar_id: @private_profile.secure_id,
        clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
      }

    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Avatar not available for B2B usage", json_response["error"]
  end

  test "should reject non-existent avatar" do
    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer #{@active_partner.api_key}" },
      params: {
        avatar_id: "nonexistent_id_1234567890",
        clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
      }

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Avatar not found", json_response["error"]
  end

  # Success case (will fail until AI service is running, but tests API structure)
  test "should accept valid request structure" do
    skip "Requires AI service to be running"

    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer #{@active_partner.api_key}" },
      params: {
        avatar_id: @public_profile.secure_id,
        clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
      }

    # If AI service is running, expect success
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert json_response["result_image"].present?
  end

  # API usage logging test
  test "should increment partner API calls on valid request" do
    skip "Requires AI service to be running"

    initial_count = @active_partner.api_calls_count

    post api_v1_virtual_try_on_url,
      headers: { "Authorization" => "Bearer #{@active_partner.api_key}" },
      params: {
        avatar_id: @public_profile.secure_id,
        clothing_image: fixture_file_upload('test_shirt.png', 'image/png')
      }

    @active_partner.reload
    assert_equal initial_count + 1, @active_partner.api_calls_count
  end
end
