class VirtualFittingJob < ApplicationJob
  queue_as :default

  def perform(user_id, item_id)
    user = User.find(user_id)
    item = Item.find(item_id)
    profile = user.profile

    return unless profile&.avatar_3d_file&.attached?
    return unless item.image.attached?
    return unless profile.measurements.present?

    # Download images
    avatar_temp = download_to_tempfile(profile.avatar_3d_file.blob, "avatar")
    item_temp = download_to_tempfile(item.image.blob, "item")

    begin
      # Call AI service for virtual fitting
      result_bytes = AiServiceClient.virtual_fitting(
        avatar_temp,
        item_temp,
        profile.measurements
      )

      # Attach result to item as a variant or new attachment
      item.image.attach(
        io: StringIO.new(result_bytes),
        filename: "fitted_#{item.image.filename}",
        content_type: "image/png"
      )

      Rails.logger.info("Virtual fitting completed for user #{user_id}, item #{item_id}")

    rescue StandardError => e
      Rails.logger.error("Virtual fitting failed: #{e.message}")
      raise
    ensure
      avatar_temp.close
      avatar_temp.unlink
      item_temp.close
      item_temp.unlink
    end
  end

  private

  def download_to_tempfile(blob, prefix)
    temp_file = Tempfile.new([prefix, File.extname(blob.filename.to_s)])
    blob.download { |chunk| temp_file.write(chunk) }
    temp_file.rewind
    temp_file
  end
end
