class Api::V1::VirtualTryOnController < ApplicationController
  include ApiAuthenticatable
  skip_before_action :verify_authenticity_token

  def create
    avatar_id = params[:avatar_id]
    clothing_image = params[:clothing_image]

    unless avatar_id.present? && clothing_image.present?
      render json: { error: "avatar_id and clothing_image are required" }, status: :bad_request
      return
    end

    # Find profile by secure_id (hashed for privacy)
    profile = Profile.find_by(secure_id: avatar_id)

    unless profile
      render json: { error: "Avatar not found" }, status: :not_found
      return
    end

    # Check if avatar is available for B2B API usage
    unless profile.is_public_api
      render json: { error: "Avatar not available for B2B usage" }, status: :forbidden
      return
    end

    # Save clothing image temporarily
    clothing_temp = Tempfile.new(["clothing", ".png"])
    clothing_temp.binmode
    clothing_temp.write(clothing_image.read)
    clothing_temp.rewind

    # Get avatar image from profile
    unless profile.avatar_image.attached?
      render json: { error: "Avatar image not found" }, status: :not_found
      return
    end

    avatar_temp = Tempfile.new(["avatar", ".png"])
    avatar_temp.binmode
    avatar_temp.write(profile.avatar_image.download)
    avatar_temp.rewind

    # Call AI service for virtual fitting
    begin
      result_bytes = AiServiceClient.virtual_fitting(
        avatar_temp,
        clothing_temp,
        profile.measurements || {}
      )

      # Log API usage (subscription-based, no per-call cost)
      ApiUsageLog.create!(
        partner: current_partner,
        profile: profile,
        request_type: "virtual_try_on",
        cost: 0 # Subscription-based billing
      )

      # Return result as base64
      render json: {
        success: true,
        result_image: Base64.strict_encode64(result_bytes),
        avatar_id: avatar_id
      }
    rescue => e
      render json: { error: "Virtual fitting failed: #{e.message}" }, status: :internal_server_error
    ensure
      clothing_temp.close
      clothing_temp.unlink
      avatar_temp.close
      avatar_temp.unlink
    end
  end
end
