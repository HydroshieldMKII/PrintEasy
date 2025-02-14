class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :printer_user
  belongs_to :color
  belongs_to :filament

  validates :request, :printer_user, :color, :filament, presence: true
  validates :uniqueness: { scope: %i[request_id printer_user_id color_id filament_id], message: 'This offer already exist' }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :target_date, presence: true, comparison: { greater_than: Date.today }, format: { with: /\d{4}-\d{2}-\d{2}/ }
end
