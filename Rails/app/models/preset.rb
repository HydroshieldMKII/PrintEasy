class Preset < ApplicationRecord
  belongs_to :color
  belongs_to :filament
  belongs_to :user

  validates :color_id, :filament_id, :user_id, presence: true
  validates uniqueness: { scope: [:color_id, :filament_id, :user_id], message: "This preset already exist for this user" }
end
