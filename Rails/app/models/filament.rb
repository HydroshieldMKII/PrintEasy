class Filament < ApplicationRecord
  validates :name, presence: true, length: { maximum: 60 }, format: { with: /[a-zA-Z]/ }
  validates :size, presence: true, numericality: { only_float: true }, inclusion: { in: [1.75, 2.85] }
end
