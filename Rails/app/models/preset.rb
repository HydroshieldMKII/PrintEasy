class Preset < ApplicationRecord
  belongs_to :color
  belongs_to :filament
  belongs_to :user

  validates :color_id, :filament_id, :user_id, presence: true
  validates :color_id, uniqueness: { scope: [:filament_id, :user_id], message: "This preset already exist for this user" }
end
