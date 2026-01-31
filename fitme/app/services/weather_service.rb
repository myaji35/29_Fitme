class WeatherService
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def initialize(api_key = nil)
    @api_key = api_key || ENV["OPENWEATHER_API_KEY"]
  end

  def current_weather(city: "Seoul", country_code: "KR")
    return mock_weather_data unless @api_key.present?

    response = self.class.get(
      "/weather",
      query: {
        q: "#{city},#{country_code}",
        appid: @api_key,
        units: "metric"
      }
    )

    if response.success?
      parse_weather_response(response)
    else
      mock_weather_data
    end
  rescue StandardError => e
    Rails.logger.error("Weather API Error: #{e.message}")
    mock_weather_data
  end

  private

  def parse_weather_response(response)
    {
      temp: response["main"]["temp"],
      feels_like: response["main"]["feels_like"],
      temp_min: response["main"]["temp_min"],
      temp_max: response["main"]["temp_max"],
      weather: response["weather"].first["main"],
      description: response["weather"].first["description"],
      icon: response["weather"].first["icon"]
    }
  end

  def mock_weather_data
    {
      temp: 15.0,
      feels_like: 13.0,
      temp_min: 12.0,
      temp_max: 18.0,
      weather: "Clear",
      description: "clear sky",
      icon: "01d"
    }
  end
end
