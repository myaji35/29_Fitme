"""Body measurement extraction service"""
import io
from PIL import Image
import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)


async def extract_measurements(image_bytes: bytes, height_cm: float, weight_kg: float) -> Dict[str, Any]:
    """
    Extract body measurements from image using height and weight

    Args:
        image_bytes: Input full-body image
        height_cm: User height in cm
        weight_kg: User weight in kg

    Returns:
        Dictionary with body measurements (chest, waist, hips, inseam)
    """
    try:
        # Load image
        input_image = Image.open(io.BytesIO(image_bytes))
        width, height = input_image.size

        # BMI calculation
        bmi = weight_kg / ((height_cm / 100) ** 2)

        # Estimation formulas based on BMI and height
        # These are simplified formulas for MVP
        # In production, use ML models like OpenPose + anthropometric estimation

        # Chest (가슴둘레)
        chest = estimate_chest(height_cm, weight_kg, bmi)

        # Waist (허리둘레)
        waist = estimate_waist(height_cm, weight_kg, bmi)

        # Hips (엉덩이둘레)
        hips = estimate_hips(height_cm, weight_kg, bmi)

        # Inseam (다리 안쪽 길이)
        inseam = estimate_inseam(height_cm)

        # Shoulder width (어깨너비)
        shoulder = estimate_shoulder(height_cm, bmi)

        # Arm length (팔길이)
        arm_length = estimate_arm_length(height_cm)

        measurements = {
            "chest": round(chest, 1),
            "waist": round(waist, 1),
            "hips": round(hips, 1),
            "inseam": round(inseam, 1),
            "shoulder": round(shoulder, 1),
            "arm_length": round(arm_length, 1),
            "bmi": round(bmi, 2),
            "status": "estimated"
        }

        logger.info(f"Body measurements extracted: {measurements}")
        return measurements

    except Exception as e:
        logger.error(f"Measurement extraction failed: {str(e)}")
        raise


def estimate_chest(height_cm: float, weight_kg: float, bmi: float) -> float:
    """Estimate chest circumference"""
    # Formula based on height and BMI
    base_chest = height_cm * 0.52
    bmi_adjustment = (bmi - 22) * 2
    return base_chest + bmi_adjustment


def estimate_waist(height_cm: float, weight_kg: float, bmi: float) -> float:
    """Estimate waist circumference"""
    base_waist = height_cm * 0.45
    bmi_adjustment = (bmi - 22) * 2.5
    return base_waist + bmi_adjustment


def estimate_hips(height_cm: float, weight_kg: float, bmi: float) -> float:
    """Estimate hip circumference"""
    base_hips = height_cm * 0.53
    bmi_adjustment = (bmi - 22) * 2.2
    return base_hips + bmi_adjustment


def estimate_inseam(height_cm: float) -> float:
    """Estimate inseam length"""
    # Typically 45-47% of height
    return height_cm * 0.46


def estimate_shoulder(height_cm: float, bmi: float) -> float:
    """Estimate shoulder width"""
    base_shoulder = height_cm * 0.25
    bmi_adjustment = (bmi - 22) * 0.3
    return base_shoulder + bmi_adjustment


def estimate_arm_length(height_cm: float) -> float:
    """Estimate arm length"""
    # Typically 38-40% of height
    return height_cm * 0.39
