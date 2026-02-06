class Profile < ApplicationRecord
  belongs_to :user
  has_many :api_usage_logs, dependent: :destroy

  # ActiveStorage for avatar 3D file (GLB/GLTF format) and avatar image
  has_one_attached :avatar_3d_file
  has_one_attached :avatar_image

  # Callbacks
  before_create :generate_secure_id

  # Validations
  validates :height_cm, :weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :gender, inclusion: { in: %w[male female other], allow_nil: true }
  validates :secure_id, uniqueness: true, allow_nil: true

  # Helper method to calculate age from birth_date
  def age
    return nil unless birth_date

    now = Date.today
    age = now.year - birth_date.year
    age -= 1 if now.month < birth_date.month || (now.month == birth_date.month && now.day < birth_date.day)
    age
  end

  private

  def generate_secure_id
    # Generate a unique secure_id for B2B API usage
    self.secure_id ||= SecureRandom.hex(16)
  end
end
