class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_one :profile, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :outfit_suggestions, dependent: :destroy

  # Enums
  enum role: { user: 0, admin: 1, brand_partner: 2 }

  # Callbacks
  after_create :create_default_profile

  private

  def create_default_profile
    create_profile unless profile.present?
  end
end
