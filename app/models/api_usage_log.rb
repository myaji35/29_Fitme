class ApiUsageLog < ApplicationRecord
  belongs_to :partner
  belongs_to :profile

  # Validations
  validates :request_type, presence: true
  validates :cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
