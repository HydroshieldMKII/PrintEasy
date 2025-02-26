class Order < ApplicationRecord
  belongs_to :offer
  has_many :order_status
  has_one :request, through: :offer
  has_one :review
  validates :offer_id, presence: true, uniqueness: true
  validate :offer_exists
  validate :not_the_same_user_for_offer_and_request
  validate :not_two_order_with_the_same_request
  validate :user_owns_request


  def printer
    self.offer.printer_user.user
  end

  def consumer
    self.offer.request.user
  end

  private

  def offer_exists
    if self.offer.nil?
      errors.add(:offer_id, 'Offer must exist')
      throw :abort
    end
    return true
  end
  
  def not_the_same_user_for_offer_and_request
    if self.offer.request.user == self.offer.printer_user.user
      errors.add(:offer_id, 'Consumer and printer cannot be the same user')
      return false
    end
    return true
  end

  def not_two_order_with_the_same_request
    # debugger
    if request.offers.joins(:order).count > 1
      errors.add(:offer_id, 'Request already has an order')
      return false
    end
  end

  def user_owns_request
    if self.consumer != Current.user
      errors.add(:offer_id, 'User is not owner of request')
      return false
    end
    return true
  end
end
