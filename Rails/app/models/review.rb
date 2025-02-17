class Review < ApplicationRecord
  belongs_to :order
  belongs_to :user

  has_many_attached :image

  validates :title, presence: true, length: { maximum: 30, minimum: 5 }
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :description, length: { maximum: 200 , minimum: 5 }
  validates :order_id, presence: true, uniqueness: true
  validates :user_id, presence: true
end