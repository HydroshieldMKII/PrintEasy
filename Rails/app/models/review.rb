class Review < ApplicationRecord
  belongs_to :order
  belongs_to :user

  has_many_attached :image

  before_action :set_review_user
  validates :title, presence: true, length: { maximum: 30, minimum: 5 }
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :description, length: { maximum: 200 , minimum: 5 }
  validates :order_id, presence: true, uniqueness: true
  validates :user_id, presence: true
  validate :order_belongs_to_user
  validate :order_status_permits_review

  private

  def order_belongs_to_user
    if self.order.offer.request.user != Current.user
      errors.add(:order_id, 'Order does not belong to the user')
      return false
    end
    return true
  end

  def set_review_user
    self.user_id = Current.user.id
  end

  def order_status_permits_review
    states = self.order.order_status.order(created_at: :desc).pluck(:status_name)
    if ["Arrived", "Cancelled"].include?(states.first)
      return true
    end
    errors.add(:order_id, 'Order status does not permit review')
    return false
  end
end