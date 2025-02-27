# frozen_string_literal: true

class Color < ApplicationRecord
  validates :name, presence: true, length: { maximum: 30 }, format: { with: /\A[a-zA-Z\s-]+\z/ }
end
