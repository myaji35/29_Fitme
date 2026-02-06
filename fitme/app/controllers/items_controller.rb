class ItemsController < ApplicationController
  # Development: Skip authentication for demo purposes
  # before_action :authenticate_user!
  before_action :ensure_demo_user
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @items = current_user.items.order(created_at: :desc)
    @items = @items.where(category: params[:category]) if params[:category].present?
    @items = @items.where(season: params[:season]) if params[:season].present?
  end

  def show
  end

  def try_on
    @item = current_user.items.find(params[:id])

    if current_user.profile&.avatar_3d_file&.attached?
      VirtualFittingJob.perform_later(current_user.id, @item.id)
      redirect_to @item, notice: "가상 피팅을 생성 중입니다..."
    else
      redirect_to profile_path, alert: "먼저 프로필에서 전신 사진을 업로드해주세요!"
    end
  end

  def new
    @item = current_user.items.build
  end

  def analyze_image
    # AI 이미지 분석 API 엔드포인트
    if params[:image].present?
      result = analyze_item_image(params[:image])
      render json: result
    else
      render json: { error: "이미지가 필요합니다." }, status: :unprocessable_entity
    end
  end

  def create
    @item = current_user.items.build(item_params)

    if @item.save
      # Process image in background if attached
      ProcessItemImageJob.perform_later(@item.id) if @item.image.attached?

      redirect_to items_path, notice: "아이템이 추가되었습니다. AI가 분석 중입니다..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      # Reprocess image if changed
      ProcessItemImageJob.perform_later(@item.id) if @item.image.attached? && @item.saved_change_to_attribute?(:image)

      redirect_to @item, notice: "아이템이 업데이트되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: "아이템이 삭제되었습니다."
  end

  private

  def ensure_demo_user
    unless user_signed_in?
      demo_user = User.find_or_create_by!(email: 'demo@fitme.com') do |user|
        user.password = 'password123'
        user.password_confirmation = 'password123'
      end
      sign_in(demo_user)
    end
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:category, :color, :season, :image)
  end

  def analyze_item_image(image_file)
    # 간단한 AI 분석 로직 (추후 Python 서비스 연동 시 교체)
    # 현재는 파일명과 기본 규칙으로 추정

    filename = image_file.original_filename.downcase

    # 카테고리 추정
    category = if filename.include?('shirt') || filename.include?('top') || filename.include?('sweater') || filename.include?('tshirt')
                 'top'
               elsif filename.include?('pant') || filename.include?('jean') || filename.include?('bottom') || filename.include?('trouser')
                 'bottom'
               elsif filename.include?('coat') || filename.include?('jacket') || filename.include?('outer')
                 'outer'
               elsif filename.include?('shoe') || filename.include?('sneaker') || filename.include?('boot')
                 'shoes'
               else
                 'top' # 기본값
               end

    # 색상 추정 (파일명 기반)
    color = if filename.include?('black') || filename.include?('검정')
              '검정색'
            elsif filename.include?('white') || filename.include?('흰')
              '흰색'
            elsif filename.include?('blue') || filename.include?('파랑')
              '파란색'
            elsif filename.include?('red') || filename.include?('빨강')
              '빨간색'
            elsif filename.include?('beige') || filename.include?('베이지')
              '베이지'
            elsif filename.include?('gray') || filename.include?('회')
              '회색'
            else
              '' # 빈 값으로 사용자가 직접 입력하도록
            end

    # 계절 추정 (카테고리 기반 기본 추천)
    season = case category
             when 'outer'
               'winter'
             when 'shoes'
               'spring'
             else
               'spring' # 기본값
             end

    {
      category: category,
      color: color,
      season: season,
      confidence: 0.7 # AI 신뢰도 (추후 실제 AI 사용 시 반영)
    }
  end
end
