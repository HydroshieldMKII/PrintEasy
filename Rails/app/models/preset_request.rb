class PresetRequest < ApplicationRecord
  belongs_to :request
  belongs_to :color
  belongs_to :filament
  belongs_to :printer

  validates :print_quality, presence: true, numericality: { greater_than: 0, less_than: 2 }
  validates :color_id, :filament_id, :printer_id, presence: true
  validates :request_id, uniqueness: { scope: %i[color_id filament_id printer_id print_quality], message: 'This preset already exists on this request' }  
end
