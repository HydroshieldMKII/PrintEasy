class Filament < ApplicationRecord
  validates :name, presence: true, length: { maximum: 60 }, format: { with: /\A[a-zA-Z]+\z/ }
end
