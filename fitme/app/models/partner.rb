class Partner < ApplicationRecord
  has_many :api_usage_logs, dependent: :destroy

  # Enums (Rails 8.1 syntax)
  enum :subscription_status, {
    trial: "trial",
    active: "active",
    suspended: "suspended",
    cancelled: "cancelled"
  }

  # Validations
  validates :name, presence: true
  validates :api_key, presence: true, uniqueness: true
  validates :company_name, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :monthly_fee, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :generate_api_key, on: :create
  before_validation :set_trial_period, on: :create

  # Scopes
  scope :active_subscriptions, -> { where(subscription_status: [:trial, :active]) }
  scope :needs_billing, -> { where("subscription_ends_at < ? AND subscription_status = ?", Time.current, "active") }

  # Instance methods
  def subscription_active?
    (trial? || active?) && (subscription_ends_at.nil? || subscription_ends_at > Time.current)
  end

  def days_until_expiry
    return nil unless subscription_ends_at
    ((subscription_ends_at - Time.current) / 1.day).to_i
  end

  def increment_api_calls!
    increment!(:api_calls_count)
  end

  def renew_subscription!
    update!(
      subscription_ends_at: 1.month.from_now,
      subscription_status: :active,
      last_billed_at: Time.current
    )
  end

  def suspend_subscription!
    update!(subscription_status: :suspended)
  end

  private

  def generate_api_key
    self.api_key ||= "fitme_#{SecureRandom.hex(32)}"
  end

  def set_trial_period
    self.subscription_status ||= :trial
    self.subscription_started_at ||= Time.current
    self.subscription_ends_at ||= 14.days.from_now # 14일 무료 체험
    self.monthly_fee ||= 50
  end
end
