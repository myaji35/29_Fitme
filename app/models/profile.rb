class Profile < ApplicationRecord
  belongs_to :user

  # ActiveStorage for avatar 3D file (GLB/GLTF format)
  has_one_attached :avatar_3d_file

  # Validations
  validates :height_cm, :weight_kg, presence: true, numericality: { greater_than: 0 }
end
