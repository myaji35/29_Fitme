class Partner < ApplicationRecord
  has_many :api_usage_logs, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :api_key, presence: true, uniqueness: true

  # Callbacks
  before_create :generate_api_key

  private

  def generate_api_key
    self.api_key ||= SecureRandom.hex(32)
  end
end
