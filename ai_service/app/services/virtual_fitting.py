"""Virtual fitting service - 2.5D warping"""
import io
from PIL import Image
import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)


async def apply_virtual_fitting(avatar_image_bytes: bytes, clothing_image_bytes: bytes, measurements: Dict[str, float]) -> bytes:
    """
    Apply clothing to avatar using 2.5D warping

    For MVP: Simple overlay with basic transformations
    Future: Deep learning-based virtual try-on (VITON, VTON-HD)

    Args:
        avatar_image_bytes: Avatar image
        clothing_image_bytes: Clothing item image (background removed)
        measurements: Body measurements for proper scaling

    Returns:
        Composited image bytes
    """
    try:
        # Load images
        avatar_img = Image.open(io.BytesIO(avatar_image_bytes))
        clothing_img = Image.open(io.BytesIO(clothing_image_bytes))

        # Convert to RGBA for transparency
        if avatar_img.mode != 'RGBA':
            avatar_img = avatar_img.convert('RGBA')
        if clothing_img.mode != 'RGBA':
            clothing_img = clothing_img.convert('RGBA')

        # Simple overlay for MVP
        # TODO: Implement proper warping based on body keypoints
        # Future: Use VITON-HD or similar models

        # Scale clothing to fit avatar
        avatar_width, avatar_height = avatar_img.size
        clothing_scaled = scale_clothing_to_avatar(clothing_img, avatar_width, avatar_height, measurements)

        # Position clothing on avatar (simple center placement)
        position = calculate_clothing_position(avatar_width, avatar_height, clothing_scaled.size)

        # Create composite
        composite = avatar_img.copy()
        composite.paste(clothing_scaled, position, clothing_scaled)

        # Convert to bytes
        output_buffer = io.BytesIO()
        composite.save(output_buffer, format="PNG")
        output_bytes = output_buffer.getvalue()

        logger.info("Virtual fitting applied successfully")
        return output_bytes

    except Exception as e:
        logger.error(f"Virtual fitting failed: {str(e)}")
        raise


def scale_clothing_to_avatar(clothing_img: Image.Image, avatar_width: int, avatar_height: int, measurements: Dict[str, float]) -> Image.Image:
    """
    Scale clothing item to fit avatar based on measurements
    """
    # Simple scaling for MVP (60% of avatar width)
    target_width = int(avatar_width * 0.6)
    aspect_ratio = clothing_img.height / clothing_img.width
    target_height = int(target_width * aspect_ratio)

    return clothing_img.resize((target_width, target_height), Image.Resampling.LANCZOS)


def calculate_clothing_position(avatar_width: int, avatar_height: int, clothing_size: tuple) -> tuple:
    """
    Calculate position to place clothing on avatar
    """
    clothing_width, clothing_height = clothing_size

    # Center horizontally, place in upper third vertically
    x = (avatar_width - clothing_width) // 2
    y = avatar_height // 4

    return (x, y)
