class ItemsController < ApplicationController
  before_action :authenticate_user!
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

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:category, :color, :season, :image)
  end
end
