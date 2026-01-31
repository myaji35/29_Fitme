"""Background removal service using rembg"""
import io
from rembg import remove
from PIL import Image
import logging

logger = logging.getLogger(__name__)


async def remove_background(image_bytes: bytes) -> bytes:
    """
    Remove background from image using rembg

    Args:
        image_bytes: Input image as bytes

    Returns:
        PNG image bytes with transparent background
    """
    try:
        # Load image
        input_image = Image.open(io.BytesIO(image_bytes))

        # Remove background
        output_image = remove(input_image)

        # Convert to bytes
        output_buffer = io.BytesIO()
        output_image.save(output_buffer, format="PNG")
        output_bytes = output_buffer.getvalue()

        logger.info("Background removal successful")
        return output_bytes

    except Exception as e:
        logger.error(f"Background removal failed: {str(e)}")
        raise
