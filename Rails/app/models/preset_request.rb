# frozen_string_literal: true

class PresetRequest < ApplicationRecord
  belongs_to :request
  belongs_to :color
  belongs_to :filament
  belongs_to :printer

  validates :print_quality, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 2 }
  validates :color_id, :filament_id, :printer_id, presence: true
  validates :request_id,
            uniqueness: { scope: %i[color_id filament_id printer_id print_quality] }

    def has_matching_offer_by_current_user?
      printer_user_ids = Current.user.printer_users.pluck(:id)
      return false if printer_user_ids.empty?
      
      epsilon = 0.0001
      min_quality = print_quality - epsilon
      max_quality = print_quality + epsilon
      
      request.offers.where(
        printer_user_id: printer_user_ids,
        color_id: color_id,
        filament_id: filament_id
      ).where('print_quality BETWEEN ? AND ?', min_quality, max_quality).exists?
    end
end
