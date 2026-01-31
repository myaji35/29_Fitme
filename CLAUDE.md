# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FitMe (핏미)** - AI 패션 플랫폼으로 사용자의 전신 사진 1장으로 360도 3D 아바타를 생성하고, 옷장 디지털화 및 가상 피팅, 날씨 기반 코디 추천을 제공합니다. B2B 모델로 외부 쇼핑몰에 익명화된 아바타 데이터를 API로 제공하여 수익을 창출합니다(건당 250원).

## Tech Stack: The Lite Stack

- **Backend**: Ruby on Rails 8.0
- **Database**: SQLite3 (Production Mode with WAL, LiteStream for S3 backup)
- **Job Queue**: Solid Queue (DB-based, no Redis)
- **Cache**: Solid Cache (DB-based, no Redis)
- **Frontend**: Hotwire (Turbo + Stimulus) - No SPA
- **AI/ML Service**: Python Microservice (FastAPI) - 별도 GPU 인스턴스
- **Deploy**: Kamal (Docker-based single server deployment)

## Architecture Principles

### 1. Separation of Concerns
- Rails 앱은 웹 서비스와 비즈니스 로직을 담당
- Python AI 서비스는 3D Mesh 생성, 이미지 Segmentation(누끼), 분류를 담당
- HTTP Request 또는 Shared Storage로 통신

### 2. Cost Efficiency
- 초기에는 Coolify + Docker Compose로 배포하여 비용 최소화
- SQLite Volume 설정 시 데이터 덮어쓰기 방지 필수
- 트래픽 증가 시 PostgreSQL 마이그레이션 고려 (현재는 SQLite 성능 우선)

### 3. Async Processing
- 3D 아바타 생성, 이미지 처리 등 무거운 작업은 Solid Queue로 비동기 처리
- 사용자 경험을 위해 즉시 응답 후 백그라운드 작업

## Core Features & Data Models

### 1. Avatar Generation
- 입력: 전신 사진 1장 + 키(cm) + 몸무게(kg)
- 출력: 3D 모델(GLB/GLTF) + 신체 치수(오차 ±2cm)
- 시각화: WebGL (Three.js or @google/model-viewer)
- **Model**: `Profile` - avatar_3d_file_path, measurements (JSON)

### 2. Digital Wardrobe
- rembg로 배경 제거 (Python AI 서비스)
- CLIP 기반 자동 태깅: 종류, 색상, 소재, 계절
- **Model**: `Item` - category, color, season, meta_data (JSON)

### 3. Virtual Fitting
- 3D 아바타 + 누끼 이미지 맵핑 (2.5D/3D Warping)
- 360도 회전 가능

### 4. AI Stylist
- OpenWeatherMap API 연동
- 매일 3건 코디 추천 (상의+하의+아우터)
- 알고리즘: TPO + 색상 조합 + 최근 착용 기록
- **Model**: `OutfitSuggestion` - weather_snapshot, item_ids (JSON Array)

### 5. B2B Avatar API
- **Endpoint**: `POST /api/v1/virtual-try-on`
- **Authentication**: Bearer Token (Partner API Key)
- **Monetization**: `ApiUsageLog` - 호출당 250원 과금
- **Privacy**: 개인정보 노출 금지, 익명화된 avatar_id 사용

## Database Schema (SQLite)

### Key Tables
- `users` - 회원 정보 (role: user/admin/brand_partner)
- `profiles` - 신체 정보 및 3D 아바타 파일, is_public_api (B2B 동의)
- `items` - 옷장 아이템
- `outfit_suggestions` - 코디 추천 기록 (피드백 학습용)
- `partners` - B2B 파트너 (쇼핑몰), api_key
- `api_usage_logs` - 과금 로그 (핵심 수익 모델)

### Important Notes
- `measurements`, `meta_data`, `weather_snapshot`, `item_ids` 등은 JSON 타입 활용
- SQLite WAL 모드 활성화 필수
- LiteStream으로 S3 실시간 백업

## Development Roadmap

### Phase 1: MVP (4주)
- Rails 8 + SQLite 환경 구축
- 회원가입 + 기본 옷장 (rembg 연동)
- OpenWeatherMap 연동 코디 추천 (Rule-base)
- 3D 아바타는 더미 데이터 또는 2D 피팅으로 우선 구현

### Phase 2: AI 고도화 (4주)
- Python AI 서버 구축 (3D Mesh 생성)
- 사진 → 3D 아바타 변환 파이프라인
- 신체 치수 측정 알고리즘

### Phase 3: B2B 수익화 (4주)
- Partner 대시보드
- API Gateway + 과금 로직
- 외부 쇼핑몰 연동 테스트

## External APIs & Services

- **OpenWeatherMap API**: 날씨 정보 가져오기
- **Python AI Microservice**:
  - Background Removal (rembg)
  - Image Classification (CLIP)
  - 3D Mesh Generation
  - Body Measurement Extraction

## Key Technical Decisions

1. **SQLite in Production**: Rails 8의 향상된 SQLite 지원 활용, 초기 단계에서 운영 비용 최소화
2. **Hotwire over SPA**: 빠른 개발과 SEO, 서버 중심 아키텍처
3. **Solid Queue/Cache**: Redis 의존성 제거, 단일 데이터베이스로 통합
4. **Kamal Deployment**: 단일 서버 Docker 배포로 DevOps 복잡도 감소
5. **Python Microservice**: GPU 필요 작업 분리, Rails는 웹 레이어에 집중
