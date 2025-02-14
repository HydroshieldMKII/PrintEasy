class PresetRequest < ApplicationRecord
  belongs_to :request, dependent: :destroy
  belongs_to :color
  belongs_to :filament

  validates :request_id, :color_id, :filament_id, presence: true
  validates uniqueness: { scope: [:color_id, :filament_id, :request_id], message: "This preset already exist on this request" }
end
