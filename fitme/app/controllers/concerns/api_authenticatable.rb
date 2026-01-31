module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_key
  end

  private

  def authenticate_api_key
    api_key = request.headers["Authorization"]&.gsub("Bearer ", "")

    unless api_key.present?
      render json: { error: "API key missing" }, status: :unauthorized
      return
    end

    @current_partner = Partner.find_by(api_key: api_key)

    unless @current_partner
      render json: { error: "Invalid API key" }, status: :unauthorized
      return
    end

    unless @current_partner.subscription_active?
      render json: {
        error: "Subscription expired or suspended",
        subscription_status: @current_partner.subscription_status,
        expires_at: @current_partner.subscription_ends_at
      }, status: :forbidden
      return
    end

    # Log API usage
    @current_partner.increment_api_calls!
  end

  def current_partner
    @current_partner
  end
end
