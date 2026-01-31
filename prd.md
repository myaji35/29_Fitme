Product Requirements Document (PRD): FitMe
Project Name: FitMe (핏미) Version: 1.0 (MVP) Status: Draft Tech Stack: Ruby on Rails 8, SQLite, Python (AI Microservice)

1. 개요 (Executive Summary)
FitMe는 사용자의 전신 사진 한 장으로 360도 3D 아바타를 생성하고, 옷장 속 의류를 디지털화하여 가상 피팅 및 날씨 기반 코디 추천을 제공하는 AI 패션 플랫폼입니다. 또한, 외부 쇼핑몰에 사용자의 익명화된 신체 데이터(아바타)를 API로 제공하여 수익(건당 250원)을 창출하는 B2B 모델을 포함합니다.

2. 목표 (Objectives)
User: 간편한 옷장 관리, 실패 없는 온라인 쇼핑(가상 피팅), 매일 아침 코디 고민 해결.

Business:

단일 사진 기반 3D 모델링 기술 확보.

B2B Avatar-as-a-Service 모델 구축 (외부 호출 당 과금).

Technical: Rails 8 + SQLite 기반의 단일 서버 아키텍처로 운영 비용 최소화 및 유지보수 효율성 극대화.

3. 기술 아키텍처 (Technical Architecture: The Lite Stack)
Backend Framework: Ruby on Rails 8.0

Database: SQLite3 (Production Mode)

설정: WAL 모드 활성화, busy_timeout 설정.

백업: LiteStream 등을 활용한 S3 실시간 스트리밍 백업.

Job Queue: Solid Queue (DB 기반, 별도 Redis 불필요)

Cache: Solid Cache (DB 기반, 별도 Redis 불필요)

Frontend: Hotwire (Turbo + Stimulus) - SPA 없이 빠른 반응성 구현.

AI/ML Service (Python Microservice):

Rails와 분리하여 FastAPI 등으로 구축 (GPU 인스턴스 활용).

기능: 3D Mesh 생성, 이미지 Segmentation(누끼), 분류.

통신: HTTP Request or Shared Storage.

Deploy: Kamal (Docker 컨테이너 기반 단일 서버 배포).

4. 핵심 기능 요구사항 (Functional Requirements)
4.1. 사용자 아바타 생성 (Avatar Generation)
FR-1.1: 사용자는 전신 사진 1장(가벼운 옷차림), 키(cm), 몸무게(kg)를 입력한다.

FR-1.2: 시스템은 AI를 통해 2D 이미지를 360도 회전 가능한 3D 모델(GLB/GLTF 포맷)로 변환한다. (Async Job)

FR-1.3: 생성된 3D 모델에서 신체 치수(가슴, 허리, 엉덩이, 팔/다리 길이)를 오차 범위 ±2cm 내로 추출하여 저장한다.

FR-1.4: 아바타는 WebGL(Three.js or @google/model-viewer)을 통해 웹상에서 시각화된다.

4.2. 스마트 옷장 (Digital Wardrobe)
FR-2.1: 사용자는 옷 사진을 업로드하거나 촬영한다.

FR-2.2: 시스템은 rembg (Background Removal) 기술을 이용해 배경을 투명하게 처리한다.

FR-2.3: 이미지 인식 모델(CLIP 등)을 활용해 메타데이터(종류, 색상, 소재, 계절)를 자동 태깅한다.

FR-2.4: 사용자는 자동 태깅된 정보를 수정할 수 있다.

4.3. 가상 피팅 (Virtual Fitting)
FR-3.1: 사용자의 3D 아바타 위에 등록된 옷(누끼 이미지)을 맵핑한다. (2.5D 또는 3D Warping 기술 적용).

FR-3.2: 피팅된 모습을 360도 회전하며 확인할 수 있어야 한다.

4.4. AI 코디 추천 (AI Stylist)
FR-4.1: OpenWeatherMap API를 통해 사용자의 현재 위치 날씨 정보를 가져온다.

FR-4.2: 날씨(기온, 비/눈)와 보유 옷 데이터를 매칭하여 매일 3건의 코디(상의+하의+아우터)를 추천한다.

FR-4.3: 추천 로직: TPO + 색상 조합 알고리즘 + 최근 착용 기록(중복 방지).

4.5. B2B 아바타 API (B2B Monetization)
FR-5.1: 외부 쇼핑몰용 API Key 발급 및 관리 기능.

FR-5.2: POST /api/v1/fit 요청 시, 쇼핑몰의 옷 이미지와 특정 사용자의 아바타 ID를 받아 합성이미지/3D뷰를 반환.

FR-5.3: 사용자의 실명, 연락처 등 개인정보는 절대 노출하지 않음 (Anonymized).

FR-5.4: 과금 시스템: API 호출 성공 시 BillingCounter를 증가시키고, 월말 정산 데이터(호출 수 * 250원)를 생성한다.

5. 데이터 모델링 (SQLite Schema Strategy)
SaaS 확장을 고려한 스키마 설계입니다.

Ruby
# db/schema.rb (Conceptual)

# 사용자 정보
create_table "users", force: :cascade do |t|
  t.string "email", null: false
  t.string "password_digest"
  t.integer "role", default: 0 # 0: user, 1: admin, 2: brand_partner
  t.timestamps
end

# 신체 정보 및 아바타
create_table "profiles", force: :cascade do |t|
  t.references "user", null: false, foreign_key: true
  t.float "height_cm"
  t.float "weight_kg"
  t.json "measurements" # { chest: 95, waist: 80, ... }
  t.string "avatar_3d_file_path" # ActiveStorage Key or URL
  t.boolean "is_public_api", default: true # B2B 제공 동의 여부
  t.timestamps
end

# 옷장 아이템
create_table "items", force: :cascade do |t|
  t.references "user", null: false, foreign_key: true
  t.string "category" # top, bottom, outer, shoes
  t.string "color"
  t.string "season" # spring, summer, fall, winter
  t.json "meta_data" # AI analysis raw data
  t.timestamps
end

# 코디 추천 기록 (피드백 학습용)
create_table "outfit_suggestions", force: :cascade do |t|
  t.references "user", null: false, foreign_key: true
  t.date "suggested_for_date"
  t.json "weather_snapshot"
  t.json "item_ids" # [1, 5, 10]
  t.boolean "selected", default: false
  t.timestamps
end

# B2B 파트너 (쇼핑몰)
create_table "partners", force: :cascade do |t|
  t.string "name"
  t.string "api_key", unique: true
  t.string "webhook_url"
  t.timestamps
end

# 과금 로그 (핵심 수익 모델)
create_table "api_usage_logs", force: :cascade do |t|
  t.references "partner", null: false, foreign_key: true
  t.references "profile", null: false, foreign_key: true # 사용된 아바타
  t.string "request_type" # 'virtual_try_on'
  t.integer "cost", default: 250
  t.datetime "created_at", null: false
end
6. API 명세 (Draft for B2B)
POST /api/v1/virtual-try-on
외부 쇼핑몰에서 우리 아바타를 호출할 때 사용합니다.

Header: Authorization: Bearer {PARTNER_API_KEY}

Body:

JSON
{
  "avatar_id": "user_uuid_secure_hash",
  "clothing_image_url": "https://shopping-mall.com/img/new_shirt.jpg",
  "clothing_category": "top"
}
Response (200 OK):

JSON
{
  "fitting_result_url": "https://fitme.com/result/rendered_image.jpg",
  "confidence_score": 0.95,
  "usage_id": "log_12345" // 과금 근거
}
7. 구현 로드맵 (Roadmap)
Phase 1: MVP (핵심 기능 검증) - 4주
Rails 8 + SQLite 환경 구축.

회원가입 및 기본 옷장 (사진 업로드 + rembg 연동).

OpenWeatherMap 연동 코디 추천 (Rule-base).

3D 아바타는 '더미 데이터' 혹은 간소화된 2D 피팅으로 우선 구현.

Phase 2: AI 고도화 (Avatar & Vision) - 4주
Python AI 서버 구축 (3D Mesh 생성 모델 서빙).

사용자 사진 -> 3D 아바타 변환 파이프라인 완성.

신체 치수 측정 알고리즘 적용.

Phase 3: B2B 수익화 (Monetization) - 4주
Partner용 대시보드 개발.

API Gateway 및 과금(Metering) 로직 구현.

외부 쇼핑몰 연동 테스트.

8. 개발자(CEO) 메모
비용 효율성: 초기에는 Coolify에 Docker Compose로 모두 띄워서 비용을 0에 가깝게 유지합시다.

데이터: SQLite는 파일 기반이므로 배포 시 덮어쓰지 않도록 Volume 설정에 주의해야 합니다. (Kamal 설정 시 필수 체크)

확장성: 향후 트래픽이 폭발하면 그때 PostgreSQL로 마이그레이션해도 늦지 않습니다. 현재는 SQLite의 퍼포먼스를 믿고 갑시다.