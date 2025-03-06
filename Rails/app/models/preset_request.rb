# frozen_string_literal: true

class PresetRequest < ApplicationRecord
  belongs_to :request
  belongs_to :color
  belongs_to :filament
  belongs_to :printer

  validates :print_quality, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 2 }
  validates :color_id, :filament_id, :printer_id, presence: true

  def matching_offer_by_current_user?
    printer_user = Current.user.printer_users
    return false if printer_user.empty?

    request.offers.where(
      printer_user_id: printer_user,
      color_id: color_id,
      filament_id: filament_id,
      print_quality: print_quality
    ).exists?
  end
end
