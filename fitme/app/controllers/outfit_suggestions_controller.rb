class OutfitSuggestionsController < ApplicationController
  # Development: Skip authentication for demo purposes
  # before_action :authenticate_user!
  before_action :ensure_demo_user

  def index
    @suggestions = current_user.outfit_suggestions.order(suggested_for_date: :desc).limit(10)
  end

  def show
    @suggestion = current_user.outfit_suggestions.find(params[:id])
  end

  def generate
    weather_service = WeatherService.new
    weather_data = weather_service.current_weather

    recommendation_service = OutfitRecommendationService.new(current_user)
    outfits = recommendation_service.generate_recommendations(weather_data)

    if outfits.any?
      outfits.each do |outfit|
        current_user.outfit_suggestions.create!(
          suggested_for_date: Date.today,
          weather_snapshot: weather_data,
          item_ids: outfit.values.map(&:id).compact
        )
      end

      redirect_to outfit_suggestions_path, notice: "오늘의 코디 #{outfits.count}개가 생성되었습니다!"
    else
      redirect_to items_path, alert: "옷장에 아이템을 먼저 추가해주세요!"
    end
  end

  private

  def ensure_demo_user
    unless user_signed_in?
      demo_user = User.find_or_create_by!(email: 'demo@fitme.com') do |user|
        user.password = 'password123'
        user.password_confirmation = 'password123'
      end
      sign_in(demo_user)
    end
  end
end
