# frozen_string_literal: true

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
    offer.printer_user.user
  end

  def consumer
    offer.request.user
  end

  private

  def offer_exists
    if offer.nil?
      errors.add(:offer_id, 'Offer must exist')
      throw :abort
    end
    true
  end

  def not_the_same_user_for_offer_and_request
    if offer.request.user == offer.printer_user.user
      errors.add(:offer_id, 'Consumer and printer cannot be the same user')
      return false
    end
    true
  end

  def not_two_order_with_the_same_request
    # debugger
    return unless request.offers.joins(:order).count.positive?

    errors.add(:offer_id, 'Request already has an order')
    false
  end

  def user_owns_request
    if consumer != Current.user
      errors.add(:offer_id, 'User is not owner of request')
      return false
    end
    true
  end
end
