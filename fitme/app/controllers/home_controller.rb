class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to dashboard_path
    end
  end

  def dashboard
    unless user_signed_in?
      redirect_to root_path
      return
    end

    @items = current_user.items.order(created_at: :desc).limit(6)
    @recent_suggestions = current_user.outfit_suggestions.order(created_at: :desc).limit(3)

    # Get current weather
    weather_service = WeatherService.new
    @weather = weather_service.current_weather
  end
end
