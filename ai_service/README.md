# FitMe AI Service

FastAPI-based AI microservice for FitMe platform

## Features

- **Background Removal**: Remove backgrounds from clothing images using rembg
- **Image Classification**: Classify clothing items (category, color, material, season)
- **3D Avatar Generation**: Generate 3D avatars from photos (Phase 2)

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
```
