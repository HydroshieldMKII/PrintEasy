# frozen_string_literal: true

class Filament < ApplicationRecord
  validates :name, presence: true, length: { maximum: 60 }, format: { with: /\A[a-zA-Z\s-]+\z/ }
end
