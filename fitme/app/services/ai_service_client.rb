class AiServiceClient
  include HTTParty
  base_uri ENV.fetch("AI_SERVICE_URL", "http://localhost:8000")

  def self.remove_background(image_file)
    response = post(
      "/api/v1/remove-background",
      body: { file: image_file },
      timeout: 30
    )

    if response.success?
      response.body
    else
      raise "AI Service Error: #{response.code} - #{response.message}"
    end
  end

  def self.classify_clothing(image_file)
    response = post(
      "/api/v1/classify-clothing",
      body: { file: image_file },
      timeout: 30
    )

    if response.success?
      JSON.parse(response.body)
    else
      raise "AI Service Error: #{response.code} - #{response.message}"
    end
  end

  def self.generate_avatar(image_file, height_cm, weight_kg)
    response = post(
      "/api/v1/generate-avatar",
      body: {
        file: image_file,
        height_cm: height_cm,
        weight_kg: weight_kg
      },
      timeout: 60
    )

    if response.success?
      JSON.parse(response.body)
    else
      raise "AI Service Error: #{response.code} - #{response.message}"
    end
  end
end
