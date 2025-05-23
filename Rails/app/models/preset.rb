# frozen_string_literal: true

class Preset < ApplicationRecord
  belongs_to :color
  belongs_to :filament
  belongs_to :user

  validates :print_quality, presence: true, numericality: { greater_than: 0, less_than: 2 }
  validates :color_id, :filament_id, :user_id, presence: true
  validates :user_id,
            uniqueness: { scope: %i[filament_id color_id], message: 'This preset already exist for this user' }
end
