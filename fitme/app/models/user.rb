class User < ApplicationRecord
  has_secure_password

  # Associations
  has_one :profile, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :outfit_suggestions, dependent: :destroy

  # Enums
  enum role: { user: 0, admin: 1, brand_partner: 2 }

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
