# frozen_string_literal: true

class PrinterUser < ApplicationRecord
  belongs_to :printer
  belongs_to :user
  has_many :offers, dependent: :destroy
  before_destroy :can_update?, prepend: true

  validate :can_update?, on: :update

  validates :acquired_date, presence: true
  validates :acquired_date, comparison: { less_than_or_equal_to: lambda {
    Date.current
  }, message: 'cannot be in the future' }, if: -> { acquired_date.present? }

  def last_used
    latest_printed_offer = offers.joins(order: :order_status)
                                 .where(order_status: { status_name: %w[Printing Printed] })
                                 .order('order_status.created_at DESC')
                                 .first

    printed_status = nil
    if latest_printed_offer&.order
      printed_status = latest_printed_offer.order.order_status
                                           .where(status_name: %w[Printing Printed])
                                           .order(created_at: :desc)
                                           .first
    end

    printed_status&.created_at
  end

  def can_update
    offers.empty? && offers.joins(:order).empty?
  end

  private

  def can_update?
    return if offers.empty?

    return unless offers.joins(:order).exists?

    errors.add(:base, 'Cannot update printer user with orders')
    throw(:abort)
  end
end
