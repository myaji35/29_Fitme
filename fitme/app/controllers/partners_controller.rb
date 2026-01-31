class PartnersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_partner, only: [:show, :edit, :update, :dashboard]
  before_action :authorize_partner, only: [:show, :edit, :update, :dashboard]

  def index
    if current_user.admin?
      @partners = Partner.all.order(created_at: :desc)
    else
      redirect_to root_path, alert: "접근 권한이 없습니다."
    end
  end

  def show
  end

  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(partner_params)

    if @partner.save
      redirect_to partner_path(@partner), notice: "파트너 계정이 성공적으로 생성되었습니다. 14일 무료 체험이 시작되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @partner.update(partner_params)
      redirect_to partner_path(@partner), notice: "파트너 정보가 업데이트되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def dashboard
    @api_usage_logs = @partner.api_usage_logs.order(created_at: :desc).limit(100)
    @total_api_calls = @partner.api_calls_count
    @days_until_expiry = @partner.days_until_expiry

    # Calculate this month's usage
    @this_month_calls = @partner.api_usage_logs
      .where("created_at >= ?", Time.current.beginning_of_month)
      .count
  end

  def renew_subscription
    unless current_user.admin?
      redirect_to root_path, alert: "접근 권한이 없습니다."
      return
    end

    @partner.renew_subscription!
    redirect_to edit_partner_path(@partner), notice: "구독이 1개월 연장되었습니다."
  end

  def suspend_subscription
    unless current_user.admin?
      redirect_to root_path, alert: "접근 권한이 없습니다."
      return
    end

    @partner.suspend_subscription!
    redirect_to edit_partner_path(@partner), notice: "구독이 일시정지되었습니다."
  end

  private

  def set_partner
    @partner = Partner.find(params[:id])
  end

  def authorize_partner
    unless current_user.admin? || current_user.brand_partner?
      redirect_to root_path, alert: "접근 권한이 없습니다."
    end
  end

  def partner_params
    params.require(:partner).permit(
      :name,
      :company_name,
      :contact_email,
      :website_url,
      :monthly_fee
    )
  end
end
