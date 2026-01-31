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
  validates :secure_id, uniqueness: true, allow_nil: true

  private

  def generate_secure_id
    # Generate a unique secure_id for B2B API usage
    self.secure_id ||= SecureRandom.hex(16)
  end
end
