class PresetRequest < ApplicationRecord
  belongs_to :request
  belongs_to :color
  belongs_to :filament
  
  validates :request_id, :color_id, :filament_id, presence: true
  validates :request_id, uniqueness: { scope: [:color_id, :filament_id], message: "This preset already exists on this request" }
end
