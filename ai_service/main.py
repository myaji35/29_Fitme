from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import logging

from app.services.background_removal import remove_background
from app.services.image_classification import classify_clothing
from app.services.body_measurement import extract_measurements
from app.services.avatar_3d_generator import generate_3d_avatar
from app.services.virtual_fitting import apply_virtual_fitting

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FitMe AI Service",
    description="AI microservice for 3D avatar generation, background removal, and image classification",
    version="1.0.0"
)

# CORS middleware for Rails app communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class HealthResponse(BaseModel):
    status: str
    message: str


@app.get("/", response_model=HealthResponse)
async def root():
    """Health check endpoint"""
    return HealthResponse(status="ok", message="FitMe AI Service is running")


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(status="ok", message="Service is healthy")


@app.post("/api/v1/remove-background")
async def remove_bg(
    file: UploadFile = File(..., description="Image file to process")
):
    """
    Remove background from clothing image

    Args:
        file: Image file (JPEG, PNG)

    Returns:
        PNG image with transparent background
    """
    try:
        logger.info(f"Processing background removal for file: {file.filename}")

        # Read uploaded file
        image_bytes = await file.read()

        # Process image
        result_bytes = await remove_background(image_bytes)

        from fastapi.responses import Response
        return Response(
            content=result_bytes,
            media_type="image/png",
            headers={
                "Content-Disposition": f"attachment; filename=nobg_{file.filename}"
            }
        )

    except Exception as e:
        logger.error(f"Error removing background: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={"error": f"Failed to remove background: {str(e)}"}
        )


@app.post("/api/v1/classify-clothing")
async def classify_cloth(
    file: UploadFile = File(..., description="Clothing image file")
):
    """
    Classify clothing item and extract metadata

    Args:
        file: Image file (JPEG, PNG)

    Returns:
        JSON with category, color, material, season
    """
    try:
        logger.info(f"Classifying clothing image: {file.filename}")

        # Read uploaded file
        image_bytes = await file.read()

        # Classify image
        metadata = await classify_clothing(image_bytes)

        return JSONResponse(content=metadata)

    except Exception as e:
        logger.error(f"Error classifying clothing: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={"error": f"Failed to classify clothing: {str(e)}"}
        )


@app.post("/api/v1/generate-avatar")
async def generate_avatar_endpoint(
    file: UploadFile = File(..., description="Full-body photo"),
    height_cm: float = Form(..., description="Height in centimeters"),
    weight_kg: float = Form(..., description="Weight in kilograms")
):
    """
    Generate 3D avatar from single photo

    Args:
        file: Full-body photo
        height_cm: User height in cm
        weight_kg: User weight in kg

    Returns:
        JSON with 3D model URL and body measurements
    """
    try:
        logger.info(f"Generating 3D avatar for user: height={height_cm}cm, weight={weight_kg}kg")

        # Read uploaded file
        image_bytes = await file.read()

        # Step 1: Extract body measurements
        measurements = await extract_measurements(image_bytes, height_cm, weight_kg)

        # Step 2: Generate 3D avatar
        avatar_data = await generate_3d_avatar(image_bytes, height_cm, weight_kg, measurements)

        return JSONResponse(
            content={
                "status": "success",
                "measurements": measurements,
                "avatar_data": avatar_data,
                "message": "Avatar generated successfully (Phase 2 MVP)"
            }
        )

    except Exception as e:
        logger.error(f"Error generating avatar: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={"error": f"Failed to generate avatar: {str(e)}"}
        )


@app.post("/api/v1/virtual-fitting")
async def virtual_fitting_endpoint(
    avatar_image: UploadFile = File(..., description="Avatar image"),
    clothing_image: UploadFile = File(..., description="Clothing item image"),
    measurements: str = Form(..., description="Body measurements as JSON string")
):
    """
    Apply virtual fitting - overlay clothing on avatar

    Args:
        avatar_image: Avatar/user photo
        clothing_image: Clothing item (background removed)
        measurements: JSON string of body measurements

    Returns:
        Composited image showing virtual try-on
    """
    try:
        logger.info("Processing virtual fitting request")

        # Read images
        avatar_bytes = await avatar_image.read()
        clothing_bytes = await clothing_image.read()

        # Parse measurements
        import json
        measurements_dict = json.loads(measurements)

        # Apply virtual fitting
        result_bytes = await apply_virtual_fitting(avatar_bytes, clothing_bytes, measurements_dict)

        from fastapi.responses import Response
        return Response(
            content=result_bytes,
            media_type="image/png",
            headers={
                "Content-Disposition": f"attachment; filename=virtual_fitting_result.png"
            }
        )

    except Exception as e:
        logger.error(f"Virtual fitting error: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={"error": f"Virtual fitting failed: {str(e)}"}
        )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
