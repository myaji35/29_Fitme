require "test_helper"

class B2bPartnerFlowTest < ActionDispatch::IntegrationTest
  test "complete B2B partner journey: signup -> get API key -> make API calls" do
    # Step 1: Partner signs up
    get new_partner_path
    assert_response :success

    assert_difference("Partner.count", 1) do
      post partners_path, params: {
        partner: {
          name: "신규 담당자",
          company_name: "신규 파트너사",
          contact_email: "new@partner.com",
          website_url: "https://newpartner.com"
        }
      }
    end

    partner = Partner.find_by(contact_email: "new@partner.com")
    assert_not_nil partner
    assert_equal "trial", partner.subscription_status
    assert partner.api_key.start_with?("fitme_")
    assert partner.days_until_expiry >= 13  # Should be 13 or 14 days

    # Step 2: Partner views dashboard
    # (Would require authentication - skipped in integration test)

    # Step 3: Partner makes API call
    public_profile = profiles(:user_profile)

    # Valid API call
    post api_v1_virtual_try_on_path,
      headers: { "Authorization" => "Bearer #{partner.api_key}" },
      params: {
        avatar_id: public_profile.secure_id
        # clothing_image would be required
      }

    # Should fail due to missing clothing_image
    assert_response :bad_request

    # Step 4: Partner's subscription expires
    partner.update!(subscription_ends_at: 1.day.ago)

    post api_v1_virtual_try_on_path,
      headers: { "Authorization" => "Bearer #{partner.api_key}" },
      params: {
        avatar_id: public_profile.secure_id
      }

    # Should fail due to expired subscription
    assert_response :forbidden
  end

  test "partner API authentication flow" do
    active_partner = partners(:active_partner)
    suspended_partner = partners(:suspended_partner)
    public_profile = profiles(:user_profile)

    # Valid API key with active subscription
    post api_v1_virtual_try_on_path,
      headers: { "Authorization" => "Bearer #{active_partner.api_key}" },
      params: { avatar_id: public_profile.secure_id }

    assert_response :bad_request  # Missing clothing_image

    # Suspended partner cannot make API calls
    post api_v1_virtual_try_on_path,
      headers: { "Authorization" => "Bearer #{suspended_partner.api_key}" },
      params: { avatar_id: public_profile.secure_id }

    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Subscription expired or suspended", json_response["error"]

    # Invalid API key
    post api_v1_virtual_try_on_path,
      headers: { "Authorization" => "Bearer invalid_key_12345" },
      params: { avatar_id: public_profile.secure_id }

    assert_response :unauthorized

    # Missing API key
    post api_v1_virtual_try_on_path,
      params: { avatar_id: public_profile.secure_id }

    assert_response :unauthorized
  end
end
