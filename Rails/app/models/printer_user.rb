# frozen_string_literal: true

class PrinterUser < ApplicationRecord
  belongs_to :printer
  belongs_to :user
  has_many :offers, dependent: :destroy
  before_destroy :can_destroy?, prepend: true

  validates :acquired_date, presence: true
  validates :acquired_date, comparison: { less_than_or_equal_to: lambda {
    Date.current
  }, message: 'cannot be in the future' }, if: -> { acquired_date.present? }

  def last_review_image
    completed_offer = offers
                      .joins(order: [:review, :order_status, { review: :images_attachments }])
                      .where(order_status: { status_name: %w[Printed Shipped Arrived] })
                      .where('reviews.id IS NOT NULL')
                      .order('reviews.created_at DESC')
                      .first

    return nil unless completed_offer && completed_offer.order.review.images.attached?

    review = completed_offer.order.review
    image = review.images.first

    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
  end

  def last_used
    latest_printed_offer = offers.joins(order: :order_status)
                                 .where(order_status: { status_name: %w[Printing Printed] })
                                 .order('order_status.created_at DESC')
                                 .first

    # debugger

    return nil unless latest_printed_offer

    printed_status = latest_printed_offer.order.order_status
                                         .where(status_name: %w[Printing Printed])
                                         .order(created_at: :desc)
                                         .first

    printed_status.created_at
  end

  def can_delete
    offers.empty? && offers.joins(:order).empty?
  end

  private

  def can_destroy?
    return if offers.empty?

    return unless offers.joins(:order).exists?

    errors.add(:base, 'Cannot delete printer user with orders')
    throw(:abort)
  end
end
