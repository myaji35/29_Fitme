class OutfitRecommendationService
  def initialize(user)
    @user = user
    @items = user.items
  end

  def generate_recommendations(weather_data)
    return [] if @items.empty?

    recommendations = []
    3.times do
      outfit = build_outfit(weather_data)
      recommendations << outfit if outfit.present?
    end

    recommendations
  end

  private

  def build_outfit(weather_data)
    temp = weather_data[:temp]
    is_rainy = weather_data[:weather].downcase.include?("rain")

    outfit = {
      top: select_top(temp),
      bottom: select_bottom(temp),
      outer: select_outer(temp, is_rainy),
      shoes: select_shoes(is_rainy)
    }.compact

    return nil if outfit[:top].nil? || outfit[:bottom].nil?

    outfit
  end

  def select_top(temp)
    season = temperature_to_season(temp)
    tops = @items.where(category: "top")

    if season.present?
      tops = tops.where(season: season).or(tops.where(season: nil))
    end

    tops.order("RANDOM()").first
  end

  def select_bottom(temp)
    season = temperature_to_season(temp)
    bottoms = @items.where(category: "bottom")

    if season.present?
      bottoms = bottoms.where(season: season).or(bottoms.where(season: nil))
    end

    bottoms.order("RANDOM()").first
  end

  def select_outer(temp, is_rainy)
    return nil if temp > 20

    outers = @items.where(category: "outer")

    if is_rainy
      # Prefer waterproof materials in metadata
      outers.order("RANDOM()").first
    elsif temp < 10
      # Cold weather
      outers.where(season: ["fall", "winter", nil]).order("RANDOM()").first
    else
      # Mild weather
      outers.order("RANDOM()").first
    end
  end

  def select_shoes(is_rainy)
    shoes = @items.where(category: "shoes")

    if is_rainy
      # Prefer boots or waterproof shoes
      shoes.order("RANDOM()").first
    else
      shoes.order("RANDOM()").first
    end
  end

  def temperature_to_season(temp)
    case temp
    when -Float::INFINITY..5
      "winter"
    when 5..15
      ["spring", "fall"]
    when 15..25
      "spring"
    else
      "summer"
    end
  end
end
