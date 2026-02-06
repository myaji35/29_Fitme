class HomeController < ApplicationController
  def index
    # 랜딩페이지 렌더링 (로그인 여부와 관계없이)
  end

  def dashboard
    # Development: Auto-login demo user if not authenticated
    unless user_signed_in?
      demo_user = User.find_or_create_by!(email: 'demo@fitme.com') do |user|
        user.password = 'password123'
        user.password_confirmation = 'password123'
      end
      sign_in(demo_user)
    end

    # Create mock items if none exist (for demo purposes)
    if current_user.items.empty?
      create_mock_items_for_demo
    end

    # Create mock outfit suggestions if none exist (for demo purposes)
    if current_user.outfit_suggestions.empty?
      create_mock_suggestions_for_demo
    end

    @items = current_user.items.order(created_at: :desc).limit(6)
    @recent_suggestions = current_user.outfit_suggestions.order(created_at: :desc).limit(3)

    # Get current weather
    weather_service = WeatherService.new
    @weather = weather_service.current_weather
  end

  private

  def create_mock_items_for_demo
    mock_items = [
      { category: 'top', color: '#FF6B6B', season: 'summer' },
      { category: 'top', color: '#4ECDC4', season: 'spring' },
      { category: 'top', color: '#FFE66D', season: 'fall' },
      { category: 'bottom', color: '#95E1D3', season: 'summer' },
      { category: 'bottom', color: '#1A535C', season: 'winter' },
      { category: 'bottom', color: '#3D5A80', season: 'fall' },
      { category: 'outer', color: '#293241', season: 'winter' },
      { category: 'outer', color: '#EE6C4D', season: 'fall' },
      { category: 'shoes', color: '#000000', season: 'spring' },
      { category: 'shoes', color: '#FFFFFF', season: 'summer' },
      { category: 'top', color: '#98C1D9', season: 'spring' },
      { category: 'outer', color: '#E0FBFC', season: 'spring' }
    ]

    mock_items.each do |item_data|
      current_user.items.create!(item_data)
    end
  end

  def create_mock_suggestions_for_demo
    mock_suggestions = [
      {
        suggested_for_date: Date.today,
        weather_snapshot: { temp: 22, feels_like: 20, description: '맑음' }.to_json,
        item_ids: current_user.items.limit(3).pluck(:id)
      },
      {
        suggested_for_date: Date.today - 1.day,
        weather_snapshot: { temp: 18, feels_like: 16, description: '흐림' }.to_json,
        item_ids: current_user.items.limit(3).pluck(:id)
      },
      {
        suggested_for_date: Date.today - 2.days,
        weather_snapshot: { temp: 25, feels_like: 24, description: '화창함' }.to_json,
        item_ids: current_user.items.limit(3).pluck(:id)
      },
      {
        suggested_for_date: Date.today - 3.days,
        weather_snapshot: { temp: 15, feels_like: 13, description: '비' }.to_json,
        item_ids: current_user.items.limit(3).pluck(:id)
      },
      {
        suggested_for_date: Date.today - 4.days,
        weather_snapshot: { temp: 20, feels_like: 19, description: '구름 조금' }.to_json,
        item_ids: current_user.items.limit(3).pluck(:id)
      }
    ]

    mock_suggestions.each do |suggestion_data|
      current_user.outfit_suggestions.create!(suggestion_data)
    end
  end
end
