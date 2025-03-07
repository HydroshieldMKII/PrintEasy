# frozen_string_literal: true

class PresetRequest < ApplicationRecord
  belongs_to :request
  belongs_to :color
  belongs_to :filament
  belongs_to :printer

  validates :print_quality, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 2 }
  validates :color_id, :filament_id, :printer_id, presence: true

  def matching_offer_by_current_user?
    matching_printer_users = Current.user.printer_users.where(printer: printer_id)
    return false if matching_printer_users.empty?

    request.offers.where(
      printer_user_id: matching_printer_users,
      color_id: color_id,
      filament_id: filament_id,
      print_quality: print_quality
    ).exists?
  end
end
