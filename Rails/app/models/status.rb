# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :order_status

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
end
