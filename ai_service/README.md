# FitMe AI Service

FastAPI-based AI microservice for FitMe platform

## Features

- **Background Removal**: Remove backgrounds from clothing images using rembg
- **Image Classification**: Classify clothing items (category, color, material, season)
- **3D Avatar Generation**: Generate 3D avatars from photos with body measurements
  - BMI-based body measurement estimation
  - Extract measurements: chest, waist, hips, inseam, shoulder, arm length
  - Placeholder for PIFuHD/SMPL 3D mesh generation
- **Virtual Fitting**: 2.5D warping to overlay clothing on avatar
  - Simple overlay with scaling for MVP
  - Future: VITON-HD integration for realistic try-on

## API Documentation

When running, visit:
- Interactive docs: http://localhost:8000/docs
- Alternative docs: http://localhost:8000/redoc

## Development

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn main:app --reload
```

## Docker

```bash
# Build image
docker build -t fitme-ai-service .

# Run container
docker run -p 8000:8000 fitme-ai-service
```

## Testing Endpoints

```bash
# Health check
curl http://localhost:8000/health

# Remove background
curl -X POST http://localhost:8000/api/v1/remove-background \
  -F "file=@test_image.jpg" \
  --output result.png

# Classify clothing
curl -X POST http://localhost:8000/api/v1/classify-clothing \
  -F "file=@test_image.jpg"

# Generate avatar (Phase 2)
curl -X POST http://localhost:8000/api/v1/generate-avatar \
  -F "file=@fullbody.jpg" \
  -F "height_cm=175" \
  -F "weight_kg=70"

# Virtual fitting (Phase 2)
curl -X POST http://localhost:8000/api/v1/virtual-fitting \
  -F "avatar_image=@avatar.jpg" \
  -F "clothing_image=@shirt.png" \
  -F 'measurements={"chest":95,"waist":80,"hips":98}' \
  --output fitted_result.png
```

## Phase 2 Implementation Notes

### Body Measurement Estimation
- Uses BMI and height to estimate body measurements
- Formula-based approach for MVP
- Future: Integrate OpenPose or MediaPipe for pose detection
- Future: ML model trained on anthropometric data

### 3D Avatar Generation
- Currently returns placeholder data
- Prepared structure for PIFuHD or SMPL integration
- Future: Actual 3D mesh generation from 2D image
- Future: Texture mapping from input photo

### Virtual Fitting
- Simple 2.5D overlay with scaling
- Future: Deep learning-based try-on (VITON-HD, HR-VITON)
- Future: Pose-guided person image generation
