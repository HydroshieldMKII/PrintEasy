# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :order
  belongs_to :user

  has_many_attached :images

  before_validation :set_review_user
  validates :title, presence: true, length: { maximum: 30, minimum: 5 }
  validates :rating, presence: true,
                     numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :description, length: { maximum: 200 }
  validates :description, length: { minimum: 5 }, if: -> { description.present? }
  validates :order_id, presence: true, uniqueness: true
  validates :user_id, presence: true
  validate :order_belongs_to_user
  validate :order_status_permits_review

  def image_urls
    return unless images.attached?

    images.map do |image|
      {
        signed_id: image.signed_id,
        url: Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
      }
    end
  end

  private

  def order_belongs_to_user
    if order.nil?
      errors.add(:order_id, 'Order must exist')
      throw :abort
    end
    if order.offer.request.user != Current.user
      errors.add(:order_id, 'Order does not belong to the user')
      return false
    end
    true
  end

  def set_review_user
    return unless user_id.nil?

    self.user_id = Current.user.id
  end

  def order_status_permits_review
    states = order.order_status.order(created_at: :desc).pluck(:status_name)
    return true if %w[Arrived Cancelled].include?(states.first)

    errors.add(:order_id, 'Order status does not permit review')
    false
  end
end
