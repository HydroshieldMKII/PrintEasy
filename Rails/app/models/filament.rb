class Filament < ApplicationRecord
  validates :name, presence: true, length: { maximum: 60 }, format: { with: /[a-zA-Z]/ }
end
