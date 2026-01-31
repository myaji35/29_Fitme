class Item < ApplicationRecord
  belongs_to :user

  # ActiveStorage for item image (with background removed)
  has_one_attached :image

  # Validations
  validates :category, presence: true, inclusion: { in: %w[top bottom outer shoes] }
  validates :season, inclusion: { in: %w[spring summer fall winter], allow_nil: true }
end
