class OrderStatus < ApplicationRecord
  belongs_to :status
  belongs_to :order

  has_one_attached :image

  validates :comment, length: { maximum: 200 }
  validates :status_id, presence: true
  validates :order_id, presence: true
end