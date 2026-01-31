class GenerateAvatarJob < ApplicationJob
  queue_as :default

  def perform(profile_id)
    profile = Profile.find(profile_id)
    return unless profile.avatar_3d_file.attached?

    # Download avatar image
    image_blob = profile.avatar_3d_file.blob
    temp_file = Tempfile.new(["avatar", File.extname(image_blob.filename.to_s)])

    begin
      # Download image
      image_blob.download { |chunk| temp_file.write(chunk) }
      temp_file.rewind

      # Call AI service to generate avatar and extract measurements
      result = AiServiceClient.generate_avatar(
        temp_file,
        profile.height_cm,
        profile.weight_kg
      )

      # Update profile with measurements
      if result["measurements"].present?
        profile.update(
          measurements: result["measurements"]
        )
      end

      Rails.logger.info("Avatar generated for profile #{profile_id}: #{result}")

      # TODO: Save 3D model file when actual generation is implemented
      # For now, we just store measurements

    rescue StandardError => e
      Rails.logger.error("Failed to generate avatar for profile #{profile_id}: #{e.message}")
      raise
    ensure
      temp_file.close
      temp_file.unlink
    end
  end
end
