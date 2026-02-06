
# [0029] Fitme

## Identity
- **ID**: 0029
- **Category**: SaaS
- **Governance**: [9999] Master Root
- **Status**: Sentinel-Standardized

---
# FitMe (핏미)

AI 패션 플랫폼: 전신 사진 한 장으로 360도 3D 아바타 생성 및 가상 피팅 서비스

## 🎯 프로젝트 개요

FitMe는 사용자의 전신 사진 1장으로 360도 3D 아바타를 생성하고, 옷장 속 의류를 디지털화하여 가상 피팅 및 날씨 기반 코디 추천을 제공하는 AI 패션 플랫폼입니다.

### 핵심 기능
- 📸 **3D 아바타 생성**: 전신 사진 1장 + 키/몸무게 → 360도 3D 모델
- 👔 **스마트 옷장**: AI 배경 제거 + 자동 태깅 (종류, 색상, 소재, 계절)
- 🎭 **가상 피팅**: 3D 아바타 위에 옷 맵핑
- 🌤️ **AI 코디 추천**: 날씨 기반 매일 3건 코디 제안
- 💼 **B2B API**: 외부 쇼핑몰에 아바타 API 제공 (건당 250원)

## 🏗️ 기술 스택 (The Lite Stack)

### Backend
- **Rails 8.1.2** - Modern web framework
- **SQLite3** - Production-ready database with WAL mode
- **Solid Queue** - Background job processing (no Redis)
- **Solid Cache** - Database-backed caching (no Redis)
- **Solid Cable** - WebSocket connections (no Redis)

### Frontend
- **Hotwire (Turbo + Stimulus)** - SPA-like experience without JavaScript framework

### AI/ML Microservice
- **FastAPI** - High-performance Python API framework
- **rembg** - Background removal
- **CLIP** - Image classification (planned)
- **3D Mesh Generation** - Phase 2 implementation

### Deployment
- **Docker + Docker Compose** - Container orchestration
- **Kamal** - Single-server deployment tool
- **LiteStream** - SQLite backup to S3 (planned)

## 🚀 빠른 시작

### Prerequisites
- Docker & Docker Compose
- Ruby 3.3+ (for local development)
- Python 3.11+ (for AI service development)

### 설치 및 실행

1. **Clone repository**
```bash
git clone https://github.com/myaji35/29_Fitme.git
cd 29_Fitme
```

2. **Environment setup**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Docker Compose로 실행**
```bash
docker-compose up --build
```

4. **서비스 접속**
- Rails App: http://localhost:3000
- AI Service: http://localhost:8000
- AI Service Docs: http://localhost:8000/docs

### 로컬 개발 (without Docker)

#### Rails 앱
```bash
cd fitme
bundle install
bin/rails db:create db:migrate
bin/rails server
```

#### Python AI 서비스
```bash
cd ai_service
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

## 📊 데이터베이스 스키마

### 주요 테이블
- **users** - 사용자 정보 (email, password, role)
- **profiles** - 신체 정보 및 3D 아바타
- **items** - 옷장 아이템
- **outfit_suggestions** - AI 코디 추천 기록
- **partners** - B2B 파트너 (쇼핑몰)
- **api_usage_logs** - API 과금 로그

## 🔌 AI Service API

### Endpoints

#### 1. Background Removal
```bash
POST /api/v1/remove-background
Content-Type: multipart/form-data

file: <clothing_image>
```

#### 2. Clothing Classification
```bash
POST /api/v1/classify-clothing
Content-Type: multipart/form-data

file: <clothing_image>
```

#### 3. 3D Avatar Generation (Phase 2)
```bash
POST /api/v1/generate-avatar
Content-Type: multipart/form-data

file: <fullbody_photo>
height_cm: 175
weight_kg: 70
```

## 📅 개발 로드맵

### Phase 1: MVP (4주) - ✅ COMPLETED
- ✅ Rails 8 + SQLite 환경 구축
- ✅ 기본 데이터 모델링
- ✅ Python AI 서비스 기본 구조
- ✅ Docker Compose 설정
- ✅ 회원가입 및 기본 옷장
- ✅ rembg 배경 제거 연동
- ✅ OpenWeatherMap 코디 추천

### Phase 2: AI 고도화 (4주) - ✅ COMPLETED
- ✅ 신체 치수 측정 알고리즘 (BMI 기반 추정)
- ✅ 3D 아바타 생성 파이프라인 구축
- ✅ 가상 피팅 기능 (2.5D warping)
- ✅ Avatar Viewer UI 통합
- ✅ Background Jobs (GenerateAvatar, VirtualFitting)

### Phase 3: B2B 수익화 (4주) - PLANNED
- ⏳ Partner 대시보드
- ⏳ API Gateway + 과금 로직
- ⏳ 외부 쇼핑몰 연동

## 🧪 테스트

```bash
cd fitme
bin/rails test
```

## 📝 환경 변수

주요 환경 변수는 `.env.example` 참조

## 📜 라이선스

Copyright © 2026 FitMe Team

## 🤝 기여

Issues와 Pull Requests를 환영합니다!

## 📧 문의

프로젝트 관련 문의: [GitHub Issues](https://github.com/myaji35/29_Fitme/issues)
