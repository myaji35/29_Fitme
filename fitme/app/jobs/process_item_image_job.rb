class ProcessItemImageJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find(item_id)
    return unless item.image.attached?

    # Step 1: Remove background
    remove_background(item)

    # Step 2: Classify clothing
    classify_clothing(item)

    Rails.logger.info("Processed item #{item_id} successfully")
  rescue StandardError => e
    Rails.logger.error("Failed to process item #{item_id}: #{e.message}")
    raise
  end

  private

  def remove_background(item)
    image_blob = item.image.blob
    temp_file = Tempfile.new(["item", File.extname(image_blob.filename.to_s)])

    begin
      # Download original image
      image_blob.download { |chunk| temp_file.write(chunk) }
      temp_file.rewind

      # Call AI service
      result = AiServiceClient.remove_background(temp_file)

      # Attach processed image
      item.image.attach(
        io: StringIO.new(result),
        filename: "nobg_#{image_blob.filename}",
        content_type: "image/png"
      )
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def classify_clothing(item)
    image_blob = item.image.blob
    temp_file = Tempfile.new(["item", File.extname(image_blob.filename.to_s)])

    begin
      # Download image
      image_blob.download { |chunk| temp_file.write(chunk) }
      temp_file.rewind

      # Call AI service
      metadata = AiServiceClient.classify_clothing(temp_file)

      # Update item with metadata
      item.update(
        category: metadata["category"] || item.category,
        color: metadata["color"],
        season: metadata["season"],
        meta_data: metadata
      )
    ensure
      temp_file.close
      temp_file.unlink
    end
  end
end
